module main

import os
import time
import arrays
import log

const warmup_samples = 2
const max_samples = 20
const discard_highest_samples = 16
const fast_dir = os.dir(@FILE)
const fast_log_path = os.join_path(fast_dir, 'fast.log')

fn elog(msg string) {
	line := '${time.now().format_ss_micro()} ${msg}\n'
	if mut f := os.open_append(fast_log_path) {
		f.write_string(line) or {}
		f.close()
	}
	log.info(msg)
}
fn lexec(cmd string) string {
	elog('lexec: ${cmd}')
	return os.execute_or_exit(cmd).output.trim_right('\r\n')
}

fn main() {
	total_sw := time.new_stopwatch()
	elog('fast.v generator start')
	defer {
		elog('fast.v generator end, total: ${total_sw.elapsed().milliseconds():6} ms')
	}

	// fetch the last commit's hash
	commit := lexec('git rev-parse HEAD')[..8]
	message := lexec('git log --pretty=format:"%s" -n1 ${commit}')
	commit_date := lexec('git log -n1 --pretty="format:%at" ${commit}')
	date := time.unix(commit_date.i64())
	elog('	Benchmarking commit ${commit} , with commit message: "${message}", commit_date: ${commit_date}, date: ${date}')
	elog('	Building compiler')
	lexec('v -o papyrus_fast -prod -gc none compiler.v')

	if !os.is_dir("____fast_vm_tests") {
		//os.rmdir("____fast_vm_tests") !
		os.mkdir("____fast_vm_tests", os.MkdirParams{}) !
	}

	// measure
	diff1 := measure('papyrus_fast compile -i ".\\test-files\\vm-tests" -o "____fast_vm_tests"', 'skymp vm tests src')
	// measure
	diff1nc := measure('papyrus_fast compile -i ".\\test-files\\vm-tests" -o "____fast_vm_tests" -nocache', 'skymp vm tests src(nocache)')
	// measure
	diff2 := measure('papyrus_fast compile -i "M:\\Steam\\steamapps\\common\\Skyrim Special Edition\\Data\\Scripts\\Source" -o "____fast_vm_tests"', 'skyrim src')
	// measure
	diff3 := measure('papyrus_fast compile -i "modules\\tests\\iEquip" -h "M:\\Steam\\steamapps\\common\\Skyrim Special Edition\\Data\\Scripts\\Source" -o "____fast_vm_tests"', 'iEquip src')
	// measure
	diff3nc := measure('papyrus_fast compile -i "modules\\tests\\iEquip" -h "M:\\Steam\\steamapps\\common\\Skyrim Special Edition\\Data\\Scripts\\Source" -o "____fast_vm_tests" -nocache', 'iEquip src(nocache)')

	lexec('v -o papyrus_fast.c -prod -gc none compiler.v')
	cpapyrus_size := os.file_size('papyrus_fast.c') / 1000
	scan, parse, check, cgen := measure_steps_minimal('papyrus_fast compile -i "M:\\Steam\\steamapps\\common\\Skyrim Special Edition\\Data\\Scripts\\Source" -o "____fast_vm_tests"')!

	println(commit)
	println(message)
	println(commit_date)
	println(date)
	println(diff1)
	println(diff2)
	println(diff3)
	println(diff3nc)
	
	html_message := message.replace_each(['<', '&lt;', '>', '&gt;'])
	table := os.read_file('fast-assets/table.html')!
	new_table :=
		'	<tr>
		<td>${date.format()}</td>
		<td><a target=_blank href="https://github.com/russo-2025/papyrus-compiler/commit/${commit}">${commit}</a></td>
		<td>${html_message}</td>
		<td>${diff1}ms</td>
		<td>${diff1nc}ms</td>
		<td>${diff2}ms</td>
		<td>${diff3}ms</td>
		<td>${diff3nc}ms</td>
		<td>${cpapyrus_size} KB</td>
		<td>${scan}ms</td>
		<td>${parse}ms</td>
		<td>${check}ms</td>
		<td>${cgen}ms</td>
	</tr>\n' +
		table.trim_space() + '\n'
	os.write_file('fast-assets/table.html', new_table)!

	// regenerate index.html
	header := os.read_file('fast-assets/header.html')!
	footer := os.read_file('fast-assets/footer.html')!
	mut res := os.create('fast-assets/index.html')!
	res.writeln(header)!
	res.writeln(new_table)!
	res.writeln(footer)!
	res.close()

	// TODO запись и хранение результатов куда-то
}

// measure returns milliseconds
fn measure(cmd string, description string) int {
	elog('	Measuring ${description}, warmups: ${warmup_samples}, samples: ${max_samples}, discard: ${discard_highest_samples}, with cmd: `${cmd}`')
	for _ in 0 .. warmup_samples {
		os.execute_or_exit(cmd)
	}
	mut runs := []int{}
	for r in 0 .. max_samples {
		sw := time.new_stopwatch()
		os.execute_or_exit(cmd)
		sample := int(sw.elapsed().milliseconds())
		runs << sample
		elog('	Sample ${r + 1:2}/${max_samples:2} ... ${sample} ms')
	}
	runs.sort()
	elog('	runs before discarding: ${runs}, avg: ${f64(arrays.sum(runs) or { 0 }) / runs.len:5.2f}')
	// Discard the highest times, since on AWS, they are caused by random load spikes,
	// that are unpredictable, add noise and skew the statistics, without adding useful
	// insights:
	for _ in 0 .. discard_highest_samples {
		runs.pop()
	}
	elog('	runs  after discarding: ${runs}, avg: ${f64(arrays.sum(runs) or { 0 }) / runs.len:5.2f}')
	return int(f64(arrays.sum(runs) or { 0 }) / runs.len)
}

fn measure_steps_minimal(cmd string) !(int, int, int, int) {
	elog('measure_steps_minimal ${cmd}, samples: ${max_samples}')
	mut scans, mut parses, mut checks, mut cgens := []int{}, []int{}, []int{}, []int{}
	for i in 0 .. max_samples {
		scan, parse, check, cgen := measure_steps_one_sample(cmd)
		scans << scan
		parses << parse
		checks << check
		cgens << cgen
		elog('    [${i:2}/${max_samples:2}] scan: ${scan} ms, min parse: ${parse} ms, min check: ${check} ms, min cgen: ${cgen} ms, cmd: ${cmd}')
	}
	scan, parse, check, cgen := arrays.min(scans)!, arrays.min(parses)!, arrays.min(checks)!, arrays.min(cgens)!
	elog('measure_steps_minimal => min scan: ${scan} ms, min parse: ${parse} ms, min check: ${check} ms, min cgen: ${cgen} ms')
	return scan, parse, check, cgen
}

fn measure_steps_one_sample(cmd string) (int, int, int, int) {
	resp := os.execute_or_exit(cmd)

	mut scan, mut parse, mut check, mut cgen := 0, 0, 0, 0
	lines := resp.output.split_into_lines()
	for line in lines {
		if line.starts_with("parse headers files: ") {
			scan = line.all_after("parse headers files: ").int()
		}
		if line.starts_with("parse files: ") {
			parse = line.all_after("parse files: ").int()
		}
		if line.starts_with("check files: ") {
			check = line.all_after("check files: ").int()
		}
		if line.starts_with("gen files: ") {
			cgen = line.all_after("gen files: ").int()
		}
	}
	return scan, parse, check, cgen
}
module util

import v.vmod
import os
import runtime
import encoding.iconv

struct CmdConfig {
	line    int
	command string
}

fn cmd(c CmdConfig) string {
	x := os.execute(c.command)
	os_kind := os.user_os()
	if x.exit_code < 0 || x.exit_code == 127 || (os_kind == 'windows' && x.exit_code == 1) {
		return 'N/A'
	}
	if x.exit_code == 0 {
		if c.line < 0 {
			return x.output
		}
		output := x.output.split_into_lines()
		if output.len > 0 && output.len > c.line {
			return output[c.line]
		}
	}
	return 'Error: ${x.output}'
}

fn cpu_info() map[string]string {
	info := os.execute('cat /proc/cpuinfo')
	if info.exit_code != 0 {
		return map[string]string{}
	}

	return parse(info.output, ':')
}

fn parse(config string, sep string) map[string]string {
	mut m := map[string]string{}
	lines := config.split_into_lines()
	for line in lines {
		sline := line.trim_space()
		if sline.len == 0 || sline[0] == `#` {
			continue
		}
		x := sline.split(sep)
		if x.len < 2 {
			continue
		}
		m[x[0].trim_space().to_lower()] = x[1].trim_space().trim('"')
	}
	return m
}

fn collect_info() DeviceInfo {
	mut os_kind := os.user_os()

	mut arch_details := []string{}
	arch_details << '${runtime.nr_cpus()} cpus'
		if runtime.is_32bit() {
		arch_details << '32bit'
	}
	if runtime.is_64bit() {
		arch_details << '64bit'
	}
	if runtime.is_big_endian() {
		arch_details << 'big endian'
	}
	if runtime.is_little_endian() {
		arch_details << 'little endian'
	}
	if os_kind == 'macos' {
		arch_details << cmd(command: 'sysctl -n machdep.cpu.brand_string')
	}
	if os_kind == 'linux' {
		info := cpu_info()

		mut cpu_details := ''
		if cpu_details == '' {
			cpu_details = info['model name'] or { "`cat /proc/cpuinfo` could not run" }
		}
		if cpu_details == '' {
			cpu_details = info['hardware'] or { "`cat /proc/cpuinfo` could not run" }
		}
		if cpu_details == '' {
			cpu_details = os.uname().machine
		}
		arch_details << cpu_details
	}
	if os_kind == 'windows' {
		arch_details << cmd(
			command: 'wmic cpu get name /format:table'
			line: 2
		)
	}

	mut os_details := ''
	wsl_check := cmd(command: 'cat /proc/sys/kernel/osrelease')
	if os_kind == 'linux' {
		os_details = get_linux_os_name()
		if cpu_info()['flags'] or { "`cat /proc/cpuinfo` could not run" }.contains('hypervisor') {
			if wsl_check.contains('microsoft') {
				// WSL 2 is a Managed VM and Full Linux Kernel
				// See https://docs.microsoft.com/en-us/windows/wsl/compare-versions
				os_details += ' (WSL 2)'
			} else {
				os_details += ' (VM)'
			}
		}
		// WSL 1 is NOT a Managed VM and Full Linux Kernel
		// See https://docs.microsoft.com/en-us/windows/wsl/compare-versions
		if wsl_check.contains('Microsoft') {
			os_details += ' (WSL)'
		}
		// From https://unix.stackexchange.com/a/14346
		awk_cmd := '[ "$(awk \'\$5=="/" {print \$1}\' </proc/1/mountinfo)" != "$(awk \'\$5=="/" {print \$1}\' </proc/$$/mountinfo)" ] ; echo \$?'
		if cmd(command: awk_cmd) == '0' {
			os_details += ' (chroot)'
		}
	} else if os_kind == 'macos' {
		mut details := []string{}
		details << cmd(command: 'sw_vers -productName')
		details << cmd(command: 'sw_vers -productVersion')
		details << cmd(command: 'sw_vers -buildVersion')
		os_details = details.join(', ')
	} else if os_kind == 'windows' {
		wmic_info := cmd(
			command: 'wmic os get * /format:value'
			line:    -1
		)
		p := parse(wmic_info, '=')
		mut caption, mut build_number, mut os_arch := p['caption'], p['buildnumber'], p['osarchitecture']
		caption = iconv.encoding_to_vstring(caption.bytes(), 'ANSI') or { caption }
		build_number = iconv.encoding_to_vstring(build_number.bytes(), 'ANSI') or { build_number }
		os_arch = iconv.encoding_to_vstring(os_arch.bytes(), 'ANSI') or { os_arch }
		os_details = '${caption} ${build_number} ${os_arch}'
	} else {
		ouname := os.uname()
		os_details = '${ouname.release}, ${ouname.version}'
	}

	total_memory := f32(runtime.total_memory()) / (1024.0 * 1024.0 * 1024.0)
	free_memory := f32(runtime.free_memory()) / (1024.0 * 1024.0 * 1024.0)
/*
	mut git_status := "N/A"

	cmd_res_git := os.execute('git rev-parse --is-inside-work-tree')
	
	if cmd_res_git.exit_code != 0 || cmd_res_git.output.trim_space() != 'true' {
		git_status = 'N/A'
	}
	else {
		git_status = cmd(command: 'git -C . describe --abbrev=8 --dirty --always --tags').trim_space()
	}
*/

	default_mod := vmod.Manifest {
		name: "Papyrus Compiler"
		description: "Papyrus Compiler"
		version: "unknown"
		license: "MIT"
		repo_url: "https://github.com/russo-2025/papyrus-compiler"
		author: "russo-2025"
	}

	mod := vmod.decode(@VMOD_FILE) or { default_mod }

	return util.DeviceInfo{
		os: "${os_kind}, ${os_details}"
		processor: arch_details.join(', ')
		memory: if total_memory != 0 && free_memory != 0 {
				"${free_memory:.2}GB/${total_memory:.2}GB"
			} else {
				"N/A"
			}
		exe: arguments()[0]
		git_commit: @VMODHASH
		version: "${mod.name} v${mod.version}"
		name: mod.name
		build_type: $if prod { "release" } $else { "debug" }
		build_date: "${@BUILD_DATE} ${@BUILD_TIME} UTC"
	}
}

struct DeviceInfo {
	os	string
	processor string
	memory string
	exe string
	git_commit string
	version string
	name string
	build_type string
	build_date string
}

fn get_linux_os_name() string {
	if os.is_file('/etc/os-release') {
		if lines := os.read_file('/etc/os-release') {
			vals := parse(lines, '=')
			if vals['PRETTY_NAME'] != '' {
				return vals['PRETTY_NAME']
			}
		}
	}
	if !cmd(command: 'type lsb_release').starts_with('Error') {
		return cmd(command: 'lsb_release -d -s')
	}
	if os.is_file('/proc/version') {
		return cmd(command: 'cat /proc/version')
	}
	ouname := os.uname()
	return '${ouname.release}, ${ouname.version}'
}
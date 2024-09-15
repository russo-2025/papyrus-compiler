const delta = 18;

(function () {
    var table = document.querySelector("table");
    var isTbody = table.children[0].nodeName == "TBODY";
    var trs = isTbody
        ? table.children[0].querySelectorAll("tr")
        : table.querySelectorAll("tr");
    trs.forEach(function (tr, idx) {
        if (idx != 0 && idx + 1 < trs.length) {
            var vakueIndex1 = 3, valueIndex2 = 4, valueIndex3 = 5, valueIndex4 = 6, valueIndex5 = 7;
            var textContent = {
                value1: tr.children[vakueIndex1].textContent,
                value2: tr.children[valueIndex2].textContent,
                value3: tr.children[valueIndex3].textContent,
                value4: tr.children[valueIndex4].textContent,
                value5: tr.children[valueIndex5].textContent
            };
            var currentData = {
                value1: int(textContent.value1.slice(0, -2)),
                value2: int(textContent.value2.slice(0, -2)),
                value3: int(textContent.value3.slice(0, -2)),
                value4: int(textContent.value4.slice(0, -2)),
                value5: int(textContent.value5.slice(0, -2))
            };
            var prevData = {
                value1: int(trs[idx + 1].children[vakueIndex1].textContent.slice(0, -2)),
                value2: int(trs[idx + 1].children[valueIndex2].textContent.slice(0, -2)),
                value3: int(trs[idx + 1].children[valueIndex3].textContent.slice(0, -2)),
                value4: int(trs[idx + 1].children[valueIndex4].textContent.slice(0, -2)),
                value5: int(trs[idx + 1].children[valueIndex5].textContent.slice(0, -2))
            };
            var result = {
                value1: currentData.value1 - prevData.value1,
                value2: currentData.value2 - prevData.value2,
                value3: currentData.value3 - prevData.value3,
                value4: currentData.value4 - prevData.value4,
                value5: currentData.value5 - prevData.value5
            };
            if (Math.abs(result.value1) > delta)
                tr.children[vakueIndex1].appendChild(createElement(result.value1));
            if (Math.abs(result.value2) > delta * 2)
                tr.children[valueIndex2].appendChild(createElement(result.value2));
            if (Math.abs(result.value3) > delta * 2)
                tr.children[valueIndex3].appendChild(createElement(result.value3));
            if (Math.abs(result.value4) > delta * 2)
                tr.children[valueIndex4].appendChild(createElement(result.value4));
            if (Math.abs(result.value5) > delta * 2)
                tr.children[valueIndex5].appendChild(createElement(result.value5));
        }
    });
    function int(src) {
        return src - 0;
    }
    function getClassName(x) {
        if (x == 0)
            return "equal";
        return x < 0 ? "plus" : "minus";
    }
    function createElement(result) {
        var el = document.createElement("span");
        var parsedResult = parseResult(result);
        el.classList.add("diff");
        el.classList.add(getClassName(result));
        el.textContent = parsedResult;
        return el;
    }
    function parseResult(x) {
        if (x == 0)
            return "0";
        return x > 0 ? "+" + x : x;
    }
})();

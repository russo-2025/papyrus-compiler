const delta = 18;

(function () {
    var table = document.querySelector("table");
    var isTbody = table.children[0].nodeName == "TBODY";
    var trs = isTbody
        ? table.children[0].querySelectorAll("tr")
        : table.querySelectorAll("tr");
    trs.forEach(function (tr, idx) {
        if (idx != 0 && idx + 1 < trs.length) {
            var vc = 3, vv = 4;
            var textContent = {
                vc: tr.children[vc].textContent,
                vv: tr.children[vv].textContent
            };
            var currentData = {
                vc: int(textContent.vc.slice(0, -2)),
                vv: int(textContent.vv.slice(0, -2))
            };
            var prevData = {
                vc: int(trs[idx + 1].children[vc].textContent.slice(0, -2)),
                vv: int(trs[idx + 1].children[vv].textContent.slice(0, -2))
            };
            var result = {
                vc: currentData.vc - prevData.vc,
                vv: currentData.vv - prevData.vv
            };
            if (Math.abs(result.vc) > delta)
                tr.children[vc].appendChild(createElement(result.vc));
            if (Math.abs(result.vv) > delta * 2)
                tr.children[vv].appendChild(createElement(result.vv));
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

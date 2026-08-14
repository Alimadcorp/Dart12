const c = {
  111: "A",
  112: "B",
  113: "C",
  121: "D",
  122: "E",
  123: "F",
  131: "G",
  132: "H",
  133: "I",
  211: "J",
  212: "K",
  213: "L",
  221: "M",
  222: "N",
  223: "O",
  231: "P",
  232: "Q",
  233: "R",
  311: "S",
  312: "T",
  313: "U",
  321: "V",
  322: "W",
  323: "X",
  331: "Y",
  332: "Z",
  333: "*",
  0: " ",
  117: ".",
  227: "?",
  337: "!",
  127: ",",
  217: "-",
  237: ";",
  317: ":",
  711: "@",
  712: "#",
  713: "/",
  721: "%",
  722: "¤",
  723: "\\",
  171: "'",
  272: '"',
  811: "+",
  812: "_",
  813: "*",
  821: "÷",
  822: "=",
  823: "^",
};

let cipher = c;

const newCipher = {
  118: "0",
  181: "1",
  182: "2",
  183: "3",
  281: "4",
  282: "5",
  283: "6",
  381: "7",
  382: "8",
  383: "9",
}

const oldCipher = {
  18: "0",
  118: "1",
  128: "2",
  138: "3",
  218: "4",
  228: "5",
  238: "6",
  318: "7",
  328: "8",
  338: "9",
};

const numberCipher = {
  "0": ["1", "0", "0", "0"],
  "1": ["0", "0", "0", "1"],
  "2": ["0", "0", "1", "0"],
  "3": ["0", "1", "0", "0"],
  "4": ["0", "1", "0", "1"],
  "5": ["0", "1", "1", "0"],
  "6": ["0", "1", "1", "1"],
  "7": ["1", "1", "0", "0"],
  "8": ["1", "1", "0", "1"],
  "9": ["1", "1", "1", "0"],
}

let inverseCipher = Object.fromEntries(
  Object.entries(cipher).map(([k, v]) => [v, k])
);
function updateMaps() {
  if (state.numbers == "n") {
    cipher = { ...c, ...newCipher };
  } else {
    cipher = { ...c, ...oldCipher };
  }
  inverseCipher = Object.fromEntries(
    Object.entries(cipher).map(([k, v]) => [v, k])
  );
}

function decrypt(input) {
  let isN = state.numbers != "o",
      cC = { ...c, ...(isN ? newCipher : oldCipher) },
      cMap = isN ? { 71: 1, 72: 2, 73: 3 } : { 717: 1, 727: 2, 737: 3 },
      dW = (x, cF) => {
        let out = "", hE = false, cN = false, cW = false, cS = false, bO = false, t = "";
        for (let j = 0; j < x.length; j++) {
          let char = x[j];
          if (!/[0-9]/.test(char)) {
            out += char;
            if (/[.,!? \n\r]/.test(char)) cS = cW = false;
            continue;
          }
          t += char;
          let n1 = x[j+1], n2 = x[j+2], cT = 0,
              atWS = j - t.length + 1 == 0 || out == "" || /[ \n.!?,;:(]$/.test(out),
              cA = () => {
                if (/^(711|712|713|171)$/.test(t) && cipher[t]) return out += cipher[t], t = "", 1;
                return (t=="71"&&/^[123]$/.test(n1))||(t=="7"&&n1=="1"&&/^[123]$/.test(n2))||(t=="17"&&n1=="1")||(t=="1"&&n1=="7"&&n2=="1")?1:0;
              };

          if (cF) {
            if (cA()) continue;
            if (atWS) cT = cMap[t] || cT;
          } else {
            if (atWS) cT = cMap[t] || cT;
            if (cT == 0 && cA()) continue;
          }

          if (t == "00") cT = 4;
          if (t == "373") cT = 5;
          if (t == "0" && n1 == "0") continue;
          if (cT == 0 && !isN && ((t == "7" && /^[123]$/.test(n1)) || /^7[123]$/.test(t) && n1 == "7")) continue;

          if (cT > 0) {
            if (cT == 1) cS = false, cN = true;
            else if (cT == 2) cS = false, cW = true;
            else if (cT == 3) cS = true;
            else if (cT == 4) out += "\n", cS = cW = false;
            else if (cT == 5) out += bO ? ")" : "(", bO = !bO;
            t = "";
            continue;
          }

          if (t.length == 3 || t == "0" || (!isN && t == "18")) {
            let inc = cipher[t];
            if (inc) {
              if (/[.,!?\n\r]/.test(inc)) cS = cW = false;
              if (inc == " ") cW = false;
              out += (cN || cW || cS) ? inc : inc.toLowerCase();
              cN = false;
            } else out += `<span class='red'>${t}</span>`, hE = true;
            t = "";
          } else if (t.length > 3) out += `<span class='red'>${t}</span>`, hE = true, t = "";
        }
        if (t.length > 0) out += `<span class='red'>${t}</span>`, hE = true;
        return { O: out, E: hE };
      };

  return input
    .replace(/4/g, "11")
    .replace(/5/g, "22")
    .replace(/6/g, "33")
    .replace(/791(.*?)791/g, (_, ct) => {
      let h = "", t = "";
      for (let i = 0; i < ct.length; i++) {
        t += ct[i];
        if (t.length == 3 || t == "0" || (!isN && t == "18")) {
          if (cC[t]) h += cC[t];
          t = "";
        } else if (t.length > 3) t = "";
      }
      if (!h) return "";
      try { return `<span class='blue'>${String.fromCodePoint(parseInt(h, 16))}</span>`; }
      catch (e) { return `<span class='red'>${h}</span>`; }
    })
    .split(" ")
    .filter(x => x)
    .map(x => {
      let r = dW(x, state.capitalization == "cipher");
      if (r.E) {
        let a = dW(x, state.capitalization != "cipher");
        if (!a.E) r = a;
      }
      return r.O;
    })
    .join(" ");
}

function encrypt(input, forceCaseInsensitive = false) {
  let out = "";
  let bracketOpen = false;

  const isLetter = (ch) => {
    const up = ch.toUpperCase();
    const low = ch.toLowerCase();
    return up !== low;
  };

  const isTerminator = (ch) => {
    return [".", ",", "!", "?", "\n", "\r"].includes(ch);
  };
  const detectCapPattern = (startIdx) => {
    let wordCount = 0;
    let totalCaps = 0;
    let totalLetters = 0;
    let inWord = false;
    let firstWordEnd = -1;
    let firstWordCaps = 0;
    let firstWordLetters = 0;

    for (let i = startIdx; i < input.length; i++) {
      const ch = input[i];

      if (isTerminator(ch)) {
        break;
      }

      if (isLetter(ch)) {
        if (!inWord) {
          wordCount++;
          inWord = true;
        }
        totalLetters++;
        if (ch === ch.toUpperCase()) {
          totalCaps++;
        }

        if (wordCount === 1) {
          firstWordLetters++;
          if (ch === ch.toUpperCase()) {
            firstWordCaps++;
          }
        }
      } else if (ch === " ") {
        if (inWord && firstWordEnd === -1) {
          firstWordEnd = i;
        }
        inWord = false;
      }
    }

    if (wordCount >= 2 && totalCaps === totalLetters && totalLetters > 0) {
      for (let i = startIdx; i < input.length; i++) {
        if (isTerminator(input[i])) {
          return { type: "sentence", length: i - startIdx };
        }
      }
      return { type: "sentence", length: input.length - startIdx };
    }

    if (firstWordCaps === firstWordLetters && firstWordLetters > 1) {
      if (firstWordEnd !== -1) {
        return { type: "word", length: firstWordEnd - startIdx };
      }
      for (let i = startIdx; i < input.length; i++) {
        if (input[i] === " " || isTerminator(input[i])) {
          return { type: "word", length: i - startIdx };
        }
      }
      return { type: "word", length: input.length - startIdx };
    }

    return { type: "none", length: 0 };
  };

  for (let i = 0; i < input.length; i++) {
    const ch = input[i];

    if (ch === "\n") {
      out += "00";
      continue;
    }

    if (ch === "(" || ch === ")") {
      let handled = false;
      if (ch === "(" && !bracketOpen) {
        out += "373";
        bracketOpen = true;
        handled = true;
      } else if (ch === ")" && bracketOpen) {
        out += "373";
        bracketOpen = false;
        handled = true;
      }

      if (!handled) {
        if (state.unmatched == "unchanged") {
          out += `<span class='red'>${ch}</span>`;
        } else if (state.unmatched == "?") {
          out += "<span class='red'>?</span>";
        } else if (state.unmatched == "unicode") {
          out += `<span class='blue'>791${encrypt(
            charToUnicode(ch),
            true
          )}791</span>`;
        }
      }
      continue;
    }

    let up = ch.toUpperCase();
    const token = inverseCipher[up];

    if (!token) {
      if (state.unmatched == "unchanged") {
        out += `<span class='red'>${ch}</span>`;
      } else if (state.unmatched == "?") {
        out += "<span class='red'>?</span>";
      } else if (state.unmatched == "unicode") {
        out += `<span class='blue'>791${encrypt(
          charToUnicode(ch),
          true
        )}791</span>`;
      }
      continue;
    }

    const isLetterChar = isLetter(ch);
    const isCapital = (ch === up && isLetterChar);

    // Only handle capitalization if case sensitive mode is enabled
    if (isCapital && state.caseSensitive && !forceCaseInsensitive) {
      const pattern = detectCapPattern(i);

      if (pattern.type === "sentence") {
        if (state.numbers === "o") out += "737";
        else out += "73";
        for (let j = i; j < i + pattern.length; j++) {
          const sentCh = input[j];
          if (sentCh === "\n") {
            out += "00";
            continue;
          }
          const sentUp = sentCh.toUpperCase();
          const sentToken = inverseCipher[sentUp];
          if (sentToken) {
            out += sentToken;
          } else if (sentCh === " ") {
            out += inverseCipher[" "] || "0";
          }
        }
        i += pattern.length - 1;
        continue;
      } else if (pattern.type === "word") {
        if (state.numbers === "o") out += "727";
        else out += "72";
        let wordProcessed = 0;
        for (let j = i; j < input.length; j++) {
          const wordCh = input[j];
          if (wordCh === " " || isTerminator(wordCh)) break;

          const wordUp = wordCh.toUpperCase();
          const wordToken = inverseCipher[wordUp];
          if (wordToken) {
            out += wordToken;
            wordProcessed++;
          }
        }
        i += wordProcessed - 1;
        continue;
      } else {
        if (state.numbers === "o") out += "717";
        else out += "71";
      }
    }

    out += token;
  }

  out = out.replace(/11/g, "4").replace(/22/g, "5").replace(/33/g, "6");
  return out;
}

let s = false;

function charToUnicode(char) {
  if (!char || char.length === 0) return null;
  const codePoint = char.codePointAt(0);
  return codePoint.toString(16).toUpperCase();
}

function unicodeToChar(unicodeHex) {
  const hex = unicodeHex.replace(/^U\+/i, "");
  const codePoint = parseInt(hex, 16);
  return String.fromCodePoint(codePoint);
}

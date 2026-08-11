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
  let clean = input;

  clean = clean
    .replace(/4/g, "11")
    .replace(/5/g, "22")
    .replace(/6/g, "33");

  // Global Unicode extraction (Prioritized Pass)
  const isN = state.numbers != "o";
  const currentCipher = isN ? { ...c, ...newCipher } : { ...c, ...oldCipher };
  clean = clean.replace(/791(.*?)791/g, (match, content) => {
    let hex = "";
    let t = "";
    for (let i = 0; i < content.length; i++) {
      t += content[i];
      if (t.length === 3 || t === "0" || (!isN && t === "18")) {
        let char = currentCipher[t];
        if (char) hex += char;
        t = "";
      } else if (t.length > 3) {
        t = "";
      }
    }
    if (!hex) return "";
    try {
      return `<span class='blue'>${String.fromCodePoint(parseInt(hex, 16))}</span>`;
    } catch (e) {
      return `<span class='red'>${hex}</span>`;
    }
  });

  const parts = clean.split(" ");
  const outputs = [];

  for (let i = 0; i < parts.length; i++) {
    const x = parts[i];
    if (!x) continue;
    let result = decryptWord(x, state.capitalization === "cipher");

    if (result.hasError) {
      let altResult = decryptWord(x, state.capitalization !== "cipher");
      if (!altResult.hasError) {
        result = altResult;
      }
    }

    outputs.push(result.output);
  }

  return outputs.join(" ");
}

function decryptWord(x, cipherFirst) {
  let out = "";
  let hasError = false;
  let capNext = false;
  let capWord = false;
  let capSentence = false;
  let bracketOpen = false;

  let token = "";

  for (let j = 0; j < x.length; j++) {
    const char = x[j];

    // Pass through HTML and pre-decoded Unicode characters
    if (!/[0-9]/.test(char)) {
      out += char;
      if ([".", ",", "!", "?", " ", "\n", "\r"].includes(char)) {
        capSentence = false;
        capWord = false;
      }
      if (char === " ") capWord = false;
      continue;
    }

    token += char;

    const nextChar = x[j + 1];
    const next2Char = x[j + 2];

    let codeType = 0;
    const isN = state.numbers != "o";

    if (cipherFirst) {
      if (token === "711" || token === "712" || token === "713" || token === "171") {
        let inc = cipher[token];
        if (inc) {
          out += inc;
          token = "";
          continue;
        }
      }
      if (token === "71" && ["1", "2", "3"].includes(nextChar)) continue;
      if (token === "7" && nextChar === "1" && ["1", "2", "3"].includes(next2Char)) continue;
      if (token === "17" && nextChar === "1") continue;
      if (token === "1" && nextChar === "7" && next2Char === "1") continue;

      const isAtWordStart = (j - token.length + 1 === 0) || (out.length === 0) ||
        [" ", "\n", ".", "!", "?", ",", ";", ":", "("].includes(out[out.length - 1]);

      if (isAtWordStart) {
        if (isN) {
          if (token === "71") codeType = 1;
          else if (token === "72") codeType = 2;
          else if (token === "73") codeType = 3;
        } else {
          if (token === "717") codeType = 1;
          else if (token === "727") codeType = 2;
          else if (token === "737") codeType = 3;
        }
      }
    } else {
      const isAtWordStart = (j - token.length + 1 === 0) || (out.length === 0) ||
        [" ", "\n", ".", "!", "?", ",", ";", ":", "("].includes(out[out.length - 1]);

      if (isAtWordStart) {
        if (isN) {
          if (token === "71") codeType = 1;
          else if (token === "72") codeType = 2;
          else if (token === "73") codeType = 3;
        } else {
          if (token === "717") codeType = 1;
          else if (token === "727") codeType = 2;
          else if (token === "737") codeType = 3;
        }
      }

      if (codeType === 0) {
        if (token === "711" || token === "712" || token === "713" || token === "171") {
          let inc = cipher[token];
          if (inc) {
            out += inc;
            token = "";
            continue;
          }
        }
        if (token === "71" && ["1", "2", "3"].includes(nextChar)) continue;
        if (token === "7" && nextChar === "1" && ["1", "2", "3"].includes(next2Char)) continue;
        if (token === "17" && nextChar === "1") continue;
        if (token === "1" && nextChar === "7" && next2Char === "1") continue;
      }
    }

    if (token === "00") codeType = 4;
    if (token === "373") codeType = 5;
    if (token === "0" && nextChar === "0") continue;
    if (codeType === 0 && !isN) {
      if (token === "7" && ["1", "2", "3"].includes(nextChar)) continue;
      if ((token === "71" || token === "72" || token === "73") && nextChar === "7") continue;
    }

    if (codeType > 0) {
      if (codeType === 1) {
        capSentence = false;
        capNext = true;
      } else if (codeType === 2) {
        capSentence = false;
        capWord = true;
      } else if (codeType === 3) {
        capSentence = true;
      } else if (codeType === 4) {
        out += "\n";
        capSentence = false;
        capWord = false;
      } else if (codeType === 5) {
        if (bracketOpen) {
          out += ")";
          bracketOpen = false;
        } else {
          out += "(";
          bracketOpen = true;
        }
      }
      token = "";
      continue;
    }

    if (token.length === 3 || token === "0" || (!isN && token === "18")) {
      let inc = cipher[token];
      if (inc) {
        if ([".", ",", "!", "?", "\n", "\r"].includes(inc)) {
          capSentence = false;
          capWord = false;
        }
        if (inc === " ") capWord = false;

        let finalChar = inc;
        let doCap = capNext || capWord || capSentence;
        if (!doCap) finalChar = finalChar.toLowerCase();
        out += finalChar;
        capNext = false;
      } else {
        out += `<span class='red'>${token}</span>`;
        hasError = true;
      }
      token = "";
    } else if (token.length > 3) {
      out += `<span class='red'>${token}</span>`;
      hasError = true;
      token = "";
    }
  }
  if (token.length > 0) {
    out += `<span class='red'>${token}</span>`;
    hasError = true;
  }

  return { output: out, hasError: hasError };
}

function encrypt(text, forceCaseInsensitive = false) {
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

    for (let i = startIdx; i < text.length; i++) {
      const ch = text[i];

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
      for (let i = startIdx; i < text.length; i++) {
        if (isTerminator(text[i])) {
          return { type: "sentence", length: i - startIdx };
        }
      }
      return { type: "sentence", length: text.length - startIdx };
    }

    if (firstWordCaps === firstWordLetters && firstWordLetters > 1) {
      if (firstWordEnd !== -1) {
        return { type: "word", length: firstWordEnd - startIdx };
      }
      for (let i = startIdx; i < text.length; i++) {
        if (text[i] === " " || isTerminator(text[i])) {
          return { type: "word", length: i - startIdx };
        }
      }
      return { type: "word", length: text.length - startIdx };
    }

    return { type: "none", length: 0 };
  };

  for (let i = 0; i < text.length; i++) {
    const ch = text[i];

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
          const sentCh = text[j];
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
        for (let j = i; j < text.length; j++) {
          const wordCh = text[j];
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

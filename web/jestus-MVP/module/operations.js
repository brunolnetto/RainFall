export const add = (a, b) => a + b;

export const multiply = (a, b) => a * b;

export const subtract = (a, b) => a - b;

export const divide = (a, b) => {
  if (b === 0) {
    throw Error("0-division is not allowed");
  } else {
    return a / b;
  }
};

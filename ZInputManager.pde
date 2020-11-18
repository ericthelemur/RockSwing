import java.util.Map;
import java.util.Arrays;

enum KeyMethod {
  PRESSED, HELD, RELEASED;
}

enum ModifierKeyMethod {
  ANY, HELD, UNHELD;
}


static class InputManager {
  public static InputListener listener = new InputListener();
  HashMap<Input, Integer> inputMap = new HashMap();  // map of inputs to signals
  int c = 0;

// Register an input to signal
  void register(Input input, Integer cmd) {
    inputMap.put(input, cmd);
  }
  
  // Create new signal for input
  int register(Input input) {
    while (inputMap.containsValue(c)) c++;
    inputMap.put(input, c);
    return c;
  }

  // Check if a command has been triggered
  boolean check(Integer command) {
    for (Map.Entry entry : inputMap.entrySet()) {
      if (entry.getValue() == command && ((Input) entry.getKey()).isMatched(listener)) {
        return true;
      }
    }
    return false;
  }
  
  // Get check as int not bool
  int checkI(Integer command) {
    return check(command) ? 1 : 0;
  }
}


interface Input {
  boolean isMatched(InputListener listener);
}

// Single key press
class SingleKey implements Input {
  int keyCode;
  KeyMethod method;

  SingleKey(int keyCode, KeyMethod method) {
    this.keyCode = keyCode;
    this.method = method;
  }
  
  SingleKey(char keyPress, KeyMethod method) {
    this((int) keyPress, method);
  }

  boolean isMatched(InputListener listener) {  // Check method
    if (method == KeyMethod.PRESSED) return listener.isPressed(keyCode);
    else if (method == KeyMethod.HELD) return listener.isHeld(keyCode);
    else if (method == KeyMethod.RELEASED) return listener.isReleased(keyCode);
    return true;
  }
}

// If unsupported key is added
class KeyError extends Error {
  KeyError() {
    super("This is not a supported key type");
  }
  KeyError(String str) {
    super(str);
  }
}

// Allows for a combo of keys, triggers on hold of all but last and press/release of the last key
class KeyCombo implements Input {
  char[] chars;
  KeyMethod method;

  KeyCombo(KeyMethod method, Object... chars) {
    this.chars = verifyKeys(chars);
    this.method = method;
  }

  KeyCombo(Object... chars) {
    this(KeyMethod.PRESSED, chars);
  }

  boolean isHeld(InputListener listener) {
    for (char c : chars)
      if (!listener.isHeld(c)) return false;
    return true;
  }

// If any key has just been pressed
  boolean oneIsPressed(InputListener listener) {
    for (char c : chars)
      if (listener.isPressed(c)) return true;
    return false;
  }

// If any key has just been released
  boolean oneIsReleased(InputListener listener) {
    for (char c : chars)
      if (listener.isReleased(c)) return true;
    return false;
  }

  boolean isMatched(InputListener listener) {
    if (method == KeyMethod.HELD) return isHeld(listener);
    else if (method == KeyMethod.PRESSED) return isHeld(listener) && oneIsPressed(listener);
    else if (method == KeyMethod.RELEASED) return isHeld(listener) && oneIsReleased(listener);
    return false;
  }

  // Converts key list to consistent types
  char[] verifyKeys(Object[] chars) {
    char[] retArray = new char[chars.length];
    for (int i = 0; i < chars.length; i++) {
      Object o = chars[i];
      if (o instanceof Character) {
        retArray[i] = (char) o;
      } else if (o instanceof Integer) {
        if (0 <= (int) o && (int) o < 256) {
          retArray[i] = (char) o;
        } else throw new KeyError("Incorrect key code: "+o);
      } else throw new KeyError("Incorrect type for key: "+o.getClass());
    }
    return retArray;
  }
}

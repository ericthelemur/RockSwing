static class InputListener {
  BitSet keysPressed = new BitSet(256), keysHeld = new BitSet(256), keysReleased = new BitSet(256);
  BitSet keysHeldConsumed = new BitSet(256);

  public void reset() {  // Resets pressed and released keys at the end of each game loop
    keysPressed.set(0, keysPressed.size(), false);
    keysReleased.set(0, keysReleased.size(), false);
    keysHeldConsumed.set(0, keysReleased.size(), false);
  }
  
  // Called from keyPressed and keyReleased when key is pressed
  public void keyPressed(int kc) {
    try {
      if (!keysHeld.get(kc)) keysPressed.set(kc, true);
      keysHeld.set(kc, true);
    } catch (IndexOutOfBoundsException ignored) {}
  }

  public void keyReleased(int kc) {
    try {
      keysHeld.set(kc, false);
      keysReleased.set(kc, true);
    } catch (IndexOutOfBoundsException ignored) {}
  }
  
  // On key press for key code
  public boolean isPressed(int kc) {
    try { 
      return keysPressed.get(kc);
    } catch (IndexOutOfBoundsException ignored) {}
    return false;
  }

  // While key held for key code
  public boolean isHeld(int kc) {
    try { 
      return (!keysHeldConsumed.get(kc)) && keysHeld.get(kc);
    } catch (IndexOutOfBoundsException ignored) {}
    return false;
  }


  // On key release for key code
  public boolean isReleased(int kc) {
    try { 
      return keysReleased.get(kc);
    } catch (IndexOutOfBoundsException ignored) {}
    return false;
  }

// On key press for character
  public boolean isPressed(char c) {
    return isPressed((int) Character.toUpperCase(c));
  }

  public boolean isHeld(char c) {
    return isHeld((int) Character.toUpperCase(c));
  }

  public boolean isReleased(char c) {
    return isReleased((int) Character.toUpperCase(c));
  }
  
  
  // Consuming variants
  // On key press for key code
  public boolean isPressedC(int kc) {
    try {
      boolean v = false;
      v = keysPressed.get(kc);
      if (v) keysPressed.set(kc, false);
      return v;
    } catch (IndexOutOfBoundsException ignored) {}
    return false;
  }

  // While key held for key code
  public boolean isHeldC(int kc) {
    try { 
      boolean v = (!keysHeldConsumed.get(kc)) && keysHeld.get(kc);
      if (v) keysHeldConsumed.set(kc, false);
      return v;
    } catch (IndexOutOfBoundsException ignored) {}
    return false;
  }


  // On key release for key code
  public boolean isReleasedC(int kc) {
    try {
      boolean v = keysReleased.get(kc);
      if (v) keysReleased.set(kc, false);
      return v;
    } catch (IndexOutOfBoundsException ignored) {}
    return false;
  }

// On key press for character
  public boolean isPressedC(char c) {
    return isPressed((int) Character.toUpperCase(c));
  }

  public boolean isHeldC(char c) {
    return isHeld((int) Character.toUpperCase(c));
  }

  public boolean isReleasedC(char c) {
    return isReleased((int) Character.toUpperCase(c));
  }
}

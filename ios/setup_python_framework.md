# 📦 PythonKit + Python-Apple-support Xcode Integration Checklist

Follow these steps to integrate the Python framework and standard library into your iOS app using Xcode:

---

- [ ] **Open your project in Xcode**
    - [ ] Open `ios/Runner.xcworkspace` in Xcode (not `.xcodeproj`).

- [ ] **Add Python.xcframework to your project**
    - [ ] Right-click in the Xcode project navigator.
    - [ ] Select **Add Files to "Runner"**.
    - [ ] Navigate to `ios/Python.xcframework`.
    - [ ] Make sure **Add to target: Runner** is checked.
    - [ ] Click **Add**.

- [ ] **Embed the Python framework**
    - [ ] Select the **Runner** target.
    - [ ] Go to the **General** tab.
    - [ ] Under **Frameworks, Libraries, and Embedded Content**:
        - [ ] Find `Python.xcframework`.
        - [ ] Set **Embed** to **Embed & Sign**.

- [ ] **Add the Python standard library**
    - [ ] Right-click your project in the navigator and choose **Add Files to "Runner"**.
    - [ ] Select the folder `ios/Python.xcframework/ios-arm64/lib/python3.14`.
    - [ ] Choose **Create folder references** (so it appears as a blue folder).
    - [ ] Make sure **Add to targets: Runner** is checked.
    - [ ] (Optional) Rename the folder in Xcode to `python-stdlib` for clarity.

- [ ] **Configure Build Settings**
    - [ ] Set **User Script Sandboxing** to **No** (in Build Settings > Build Options).
    - [ ] Add `$(PROJECT_DIR)` to **Framework Search Paths** (if not already present).

- [ ] **Add code signing for Python modules**
    - [ ] Go to **Build Phases** for the Runner target.
    - [ ] Add a new **Run Script Phase** (before "Embed Frameworks").
    - [ ] Paste the following script:
      ```sh
      find "$CODESIGNING_FOLDER_PATH/python-stdlib/lib-dynload" -name "*.so" -exec /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" --timestamp=none --preserve-metadata=identifier,entitlements,flags {} \;
      ```

- [ ] **Clean and build**
    - [ ] In Xcode, select **Product > Clean Build Folder**.
    - [ ] Build and run your app.

---

**Tip:**
- If you have your own Python scripts, add them as a separate blue folder reference (not as individual files).
- If you see duplicate file errors, ensure only the blue `python-stdlib` folder is referenced in "Copy Bundle Resources". 
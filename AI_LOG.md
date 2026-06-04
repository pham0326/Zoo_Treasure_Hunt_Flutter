# AI Migration Log - Zoo Treasure Hunt (Kotlin → Flutter)

Assessment 3, COMP2012.

Workflow: Full AI. AI proposes Dart code; I build, test, report symptoms, iterate.

This log captures prompts, AI output summaries, hallucinations, wins, and time per step - feeding the report's "AI Accuracy and Hallucinations" section and the required prompts/output appendix.

---

## Phase 1 - Understand the Assignment & Set Up
**Intent:** Understand the Assignment, Analyse existing Android project & Set Up

**AI output summary:** Fully explained about the assignment and guided me through the set up.

**Did it compile first try?** Yes 

**Hallucinations / wrong APIs:** None.

**What I changed:** Nothing, used as-is.

**Time:** ~20 min

--- 

## Phase 2 - Core Migration (animal list + Found-state persistence)
### Step 2.1 - Data model (Animal class)
**Intent:** Port the Kotlin `Sighting` data class to Dart as an `Animal` class.

**AI output summary:** Full Animal class with named constructor, copyWith(), toJson(), and factory fromJson(). Fields: name, isFound, notes, timestamp, imageUrl, photoPath (nullable), latitude, longitude.

**Did it compile first try?** Yes - flutter analyze lib/animal. dart returned "No issues found!"

**Hallucinations / wrong APIs:** None.

**What I changed:** Nothing, used as-is.

**Time:** ~10 min

**Migration note - boilerplate explosion:** One Kotlin line
(`data class Sighting(...)`) became ~90 lines of Dart. Dart has no `data class` keyword, so copyWith (Kotlin's .copy), equality, and toString must be written by hand. fromJson/toJson replace the JSON handling that kotlinx.serialization / the Kotlin repository did. Newer Dart options (freezed package, or Dart 3 records) could reduce this; hand-written version chosen for clarity and to avoid an extra build dependency.

---

### Step 2.2 - Seed data (5 animals)
**Intent:** Port Kotlin getDefaultSightings() to Dart.

**AI output summary:** getDefaultAnimals() returning List<Animal>, same 5 animals, same image URLs and Adelaide coordinates as the Android app.

**Did it compile first try?** Yes - flutter analyze clean.

**Hallucinations / wrong APIs:** None.

**What I changed:** Nothing, used as-is.

**Time:** ~3 min.

---

### Step 2.3 - List UI (ListScreen + AnimalCard)
**Intent:** Port Compose ListScreen + AnimalCard to Flutter widgets.

**AI output summary:** Replaced starter counter app in main.dart with a StatefulWidget ListScreen using ListView.builder, plus an AnimalCard StatelessWidget. Tap toggles "found" via setState.

**Did it compile first try?** Yes - ran on Pixel 9 Pro XL first attempt.

**Hallucinations / wrong APIs:** None.

**What I changed:** Nothing, used as-is.

**Time:** ~20 min.

**Migration note - UI paradigm differences (Compose -> Flutter):**
| Compose | Flutter |
| @Composable fun ListScreen() | class ListScreen extends StatefulWidget |
| LazyColumn { items(list) {} } | ListView.builder(itemCount, itemBuilder) |
| Card { } | Card( child: ) |
| remember { mutableStateOf() } | setState(() {}) |
| Modifier.padding(16.dp) | Padding(padding: EdgeInsets.all(16)) |
| AsyncImage(model = url) | Image.network(url) |
Both declarative, but syntax + state model differ. Compose uses
remember/mutableStateOf; Flutter uses StatefulWidget + setState.

**State-loss observation:** "Found" state is in-memory only. Confirmed by quitting and restarting the app — Giraffe + Kangaroo reverted to "Not found".
This motivates the persistence step (2.5) and demonstrates how the new platform handles storage differently.

---

### Step 2.4 - Persistence (shared_preferences)
**Intent:** Port Kotlin FileSightingRepository (JSON in filesDir) to Flutter

**AI output summary:** AnimalRepository using shared_preferences; load on startup (initState), save on toggle. main.dart updated with async load + loading spinner.

**Did it compile first try?** Yes. App built + ran; Found state survived restart.

**Hallucinations / wrong APIs:** None. Used `flutter pub add` so the tool resolved the correct version (2.5.5) instead of trusting an AI-guessed string.

**Build warning (real, not hallucination):** shared_preferences_android applies Kotlin Gradle Plugin (KGP); future Flutter will reject this. Build still succeeded today. IRONY worth noting in report: migrated away from Kotlin, but
the Flutter plugin still depends on Kotlin underneath -> the "cross-platform" abstraction leaks.

**Storage difference:** Kotlin = manual JSON file in context.filesDir (Android only). Flutter = shared_preferences key/value; plugin picks platform storage (SharedPreferences NSUserDefaults), same Dart works on all platforms.

**Time:** ~15 min

---

## Phase 3
### Step 3.1 - Camera sensor (image_picker)
**Intent:** Port Kotlin camera flow (TakePicture + FileProvider + manual CAMERA permission) to Flutter.

**AI output summary:** Added image_picker; camera button on each card calls _picker.pickImage(source: camera); XFile.path saved on Animal + persisted; thumbnail switches to Image.file when a photo exists.

**Did it compile first try?** Yes. Camera opened on emulator, photo captured, thumbnail updated, marked FOUND, persisted
**Hallucinations / wrong APIs:** None. Used `flutter pub add` -> image_picker 1.2.2.
**Migration note — Sensor Permissions per platform:**
Kotlin: FileProvider + file_paths.xml + <provider> in manifest + manual runtime
CAMERA permission dance. Flutter image_picker: one async call
(_picker.pickImage), plugin handles FileProvider + permission internally.

BUT native permission declarations are still per-platform and NOT unified:
- Android: one line <uses-permission android:name="android.permission.CAMERA"/>
- iOS: NSCameraUsageDescription key WITH a justification string (Apple shows +
  reviews it). Two files, two styles -> "write once" doesn't cover native perms.
**Time:** ~30 min

### Step 3.2 - Polish 
**Intent:** Progress bar, search/filter, sort found-to-top, tap-to-view photo.

**AI output summary:** LinearProgressIndicator header; TextField search with case-insensitive filter; ..sort cascade to float found to top; showDialog full-photo viewer; check-circle became IconButton so card-tap = view photo.

**Did it compile first try?** Yes, all via hot reload (r).

**Hallucinations / wrong APIs:** None.

**State-management trap I had to reason about (NOT blindly accept):** filtering changes list indices. Passing the filtered index to toggle/capture would hit the WRONG animal. Fixed by looking up realIndex = _animals.indexOf(animal). This is exactly the kind of subtle off-by-one an AI can introduce - caught by testing.

**Flutter win:** hot reload (r) applied each change in <1s without losing app state - far faster than Android Studio's rebuild cycle.

**Time:** ~30 min
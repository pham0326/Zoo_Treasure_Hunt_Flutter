# AI Migration Log - Zoo Treasure Hunt (Kotlin → Flutter)

Assessment 3, COMP2012.
Workflow: Full AI. AI proposes Dart code; I build, test, report symptoms, iterate.
This log captures prompts, AI output summaries, hallucinations, wins, and
time per step - feeding the report's "AI Accuracy and Hallucinations" section
and the required prompts/output appendix.

---

## Phase 2 - Core Migration (animal list + Found-state persistence)
### Step 2.1 - [date/time]
**Intent:**
**AI output summary:**
**Did it compile first try?**
**Hallucinations / wrong APIs:**
**What I changed:**
**Time:**

---

### Step 2.2 — Seed data (5 animals)
**Intent:** Port Kotlin getDefaultSightings() to Dart
**AI output summary:** getDefaultAnimals() returning List<Animal>, same 5 animals,
same image URLs and Adelaide coordinates as the Android app
**Did it compile first try?** Yes — flutter analyze clean
**Hallucinations / wrong APIs:** None
**What I changed:** Nothing, used as-is
**Time:** ~3 min

---

### Step 2.3 — List UI (ListScreen + AnimalCard)
**Intent:** Port Compose ListScreen + AnimalCard to Flutter widgets
**AI output summary:** Replaced starter counter app in main.dart with a
StatefulWidget ListScreen using ListView.builder, plus an AnimalCard
StatelessWidget. Tap toggles "found" via setState.
**Did it compile first try?** Yes - ran on Pixel 9 Pro XL first attempt
**Hallucinations / wrong APIs:** None
**What I changed:** Nothing, used as-is
**Time:** ~20 min
**Migration note — UI paradigm differences (Compose -> Flutter):**
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

### Step 2.4 — Persistence (shared_preferences)
**Intent:** Port Kotlin FileSightingRepository (JSON in filesDir) to Flutter
**AI output summary:** AnimalRepository using shared_preferences; load on
startup (initState), save on toggle. main.dart updated with async load +
loading spinner.
**Did it compile first try?** Yes. App built + ran; Found state survived restart.
**Hallucinations / wrong APIs:** None. Used `flutter pub add` so the tool
resolved the correct version (2.5.5) instead of trusting an AI-guessed string.
**Build warning (real, not hallucination):** shared_preferences_android applies
Kotlin Gradle Plugin (KGP); future Flutter will reject this. Build still
succeeded today. IRONY worth noting in report: migrated away from Kotlin, but
the Flutter plugin still depends on Kotlin underneath -> the "cross-platform"
abstraction leaks.
**Storage difference:** Kotlin = manual JSON file in context.filesDir (Android
only). Flutter = shared_preferences key/value; plugin picks platform storage
(SharedPreferences/NSUserDefaults), same Dart works on all platforms.
**Time:** ~15 min
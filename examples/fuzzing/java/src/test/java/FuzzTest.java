import com.code_intelligence.jazzer.api.FuzzedDataProvider;

public class FuzzTest {
  public static void fuzzerTestOneInput(FuzzedDataProvider data) {
    String value = data.consumeString(128);
    if (value.isEmpty()) {
      return;
    }
    // Safe demo — no planted crash; validates Jazzer wiring in CI.
    if (value.length() > 512) {
      return;
    }
  }
}

import utest.UTest;
import routly.*;

class Test {
  static function main() {
    UTest.run([
      new TestNodeJs(),
      new TestHtml()
    ]);
  }
}

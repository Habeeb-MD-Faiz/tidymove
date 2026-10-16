# Help improve tidymove

Clearer wording, safer scripts, and reproducible bug reports are welcome. Small changes are easiest to review.

1. Describe the problem and the expected result. For larger changes, open an issue before starting.
2. Use made-up files and paths. Never include migration records, real inventories, credentials, personal screenshots, or raw agent conversations.
3. Keep the safety rules: preserve originals and partial copies, preview first, stop on uncertainty, and distinguish file checks from app recovery.
4. For script changes, add a focused synthetic test that could fail if the safety behavior breaks. Run `powershell.exe -NoProfile -File .\tests\smoke.ps1` in Windows PowerShell 5.1. Keep the resulting fixtures; the test does not clean up.
5. In your pull request, explain what changed, why, what you tested, and anything you could not test. Do not claim macOS/Linux support without target-platform evidence.

The [practical guide](docs/USAGE.md) explains script requirements and how to choose a separate test folder. Keep PowerShell scripts ASCII or UTF-8 with a BOM so PowerShell 5.1 reads them correctly. Keep shell scripts with LF line endings.

Report vulnerabilities through [SECURITY.md](SECURITY.md). Please follow the [code of conduct](CODE_OF_CONDUCT.md).

Contributions are offered under the project's [MIT license](LICENSE). Copyright remains **the tidymove authors**.

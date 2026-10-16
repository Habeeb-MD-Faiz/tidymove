# Report a safety or security problem

Use [GitHub's private vulnerability reporting form](https://github.com/Habeeb-MD-Faiz/tidymove/security/advisories/new) for anything that could expose private information, change an original, overwrite data, or bypass a safety check. Sign in to GitHub, then choose **Report a vulnerability** in the repository's Security tab.

If the private form is unavailable, do not post the details publicly. Open a public issue asking only for private vulnerability reporting to be enabled. Keep the affected files and reproduction private until the form is available. There is no public email reporting address.

Include the kit revision, operating system, expected behavior, and a small reproduction using made-up data. Do not attach secrets, raw migration logs, personal paths, or a real disk image. Explain the possible impact without trying the issue on someone else's files.

If you suspect data is at risk, stop the affected batch and keep the originals, partial copies, and private logs. An exposed credential should be revoked and replaced by its owner outside the agent conversation.

## Support and limits

This is an early volunteer-maintained project. Reports are assessed against the latest source revision; no response time or backport schedule is promised. A passing smoke test is not a security certification.

The scripts are intended for owner-reviewed ordinary data on trusted local machines with inactive destinations. Filename filters cannot find all secrets. Activation markers and manifest locks do not isolate an agent from other programs running as the same user. AI tools have their own permissions and data-handling policies.

Maintainers must enable private vulnerability reporting in the public repository's settings before advertising the private form as available. See [GitHub's setup instructions](https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository).

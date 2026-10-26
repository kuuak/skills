# Delivery

Step 8 of [`SKILL.md`](SKILL.md): the email that carries the report, then the ClickUp record once it is sent.

## Email draft

Write it in the report's language and in the register of the client's own emails (the French `tu` or `vous` they use), into `email-<report name>.md` in the audit folder, beside the report:

- **Subject:** the vulnerability's usual name, "rapport d'incident", and the sites.
- **Opening:** following the vulnerability, we proactively ran a short security audit of the sites; the report is attached. When the user already told the client about the patch, open by recalling it ("As already discussed, we patched …") and present the audit as the step beyond it.
- **En résumé:** three to five bullets mirroring the verdict cards: exploitation found or not, compromise or not, patched since when, what was cleaned.
- **On the client's side:** the open items the report assigns to the client.
- **Our offer:** the recommended follow-ups and the estimate, when the user gave one.
- **Attachments:** the PDF, and anything else attached (log archives contain visitors' IPs: say to share them only with the people concerned).

A pasted client email gets its answer here, merged into this one draft.

## ClickUp record

When the user reports the email sent, ask for the ClickUp list if they have not named it, then:

1. Create a task in that list, assigned to the user: name "Audit sécurité <usual name> (<CVE ids>) – rapport d'incident", description of two or three lines with the verdict.
2. Attach the PDF.
3. Comment: "E-mail envoyé à <recipient> le <dd.mm.yyyy> à <hh>h<mm>, avec le rapport en pièce jointe."
4. Comment the session for later recovery: its id (the last folder of your scratchpad path), `claude --resume <id>` run from the repo path, and where the report files sit.

Change the task's status only when the user names one.

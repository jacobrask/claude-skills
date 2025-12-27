import { parseArgs } from "node:util";
import { printEmailDetailed } from "./utils/format-email.ts";
import { createJamClient, getAccountId, JMAP_OPTIONS } from "./utils/jmap-client.ts";

const { values, positionals } = parseArgs({
  options: {
    help: {
      type: "boolean",
    },
  },
  allowPositionals: true,
});

if (values.help || positionals.length === 0) {
  console.log(`
Usage: node --no-warnings scripts/get-email.ts [options] <email-id>

Get full details of a specific email by ID.

Arguments:
  <email-id>    Email ID to retrieve

Options:
  --help    Show this help message

Examples:
  node scripts/get-email.ts "StrgucNsyw-3"
`);
  process.exit(values.help ? 0 : 1);
}

const emailId = positionals[0];

const jam = createJamClient();
const accountId = await getAccountId(jam);

const [result] = await jam.api.Email.get({
  accountId,
  ids: [emailId],
  properties: [
    "id",
    "subject",
    "from",
    "to",
    "cc",
    "receivedAt",
    "sentAt",
    "textBody",
    "htmlBody",
    "bodyValues",
    "size",
    "keywords",
  ],
  fetchTextBodyValues: true,
  fetchHTMLBodyValues: true,
// @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
}, JMAP_OPTIONS);

if (result.notFound?.includes(emailId)) {
  console.error(`Email ${emailId} not found`);
  process.exit(1);
}

const email = result.list[0];
printEmailDetailed(email);

import { parseArgs } from "node:util";
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
Usage: node --no-warnings scripts/delete-emails.ts [options] <email-id> [email-id...]

Permanently delete one or more emails.

Arguments:
  <email-id>    Email ID(s) to delete

Options:
  --help    Show this help message

Examples:
  node scripts/delete-emails.ts "StrgucNsyw-3"
  node scripts/delete-emails.ts "id1" "id2" "id3"
`);
  process.exit(values.help ? 0 : 1);
}

const emailIds = positionals;

const jam = createJamClient();
const accountId = await getAccountId(jam);

console.log(`Deleting ${emailIds.length} email(s)...`);

const [result] = await jam.api.Email.set({
  accountId,
  destroy: emailIds,
// @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
}, JMAP_OPTIONS);

const deletedCount = result.destroyed?.length || 0;
console.log(`Successfully deleted ${deletedCount} emails`);

if (result.notDestroyed && Object.keys(result.notDestroyed).length > 0) {
  console.log(`\nFailed to delete ${Object.keys(result.notDestroyed).length} emails:`);
  for (const [id, error] of Object.entries(result.notDestroyed)) {
    console.log(`- ${id}: ${JSON.stringify(error)}`);
  }
}

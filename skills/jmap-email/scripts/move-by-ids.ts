import { parseArgs } from "node:util";
import { createJamClient, getAccountId, JMAP_OPTIONS } from "./utils/jmap-client.ts";

const { values, positionals } = parseArgs({
  options: {
    mailbox: {
      type: "string",
    },
    help: {
      type: "boolean",
    },
  },
  allowPositionals: true,
});

if (values.help || !values.mailbox || positionals.length === 0) {
  console.log(`
Usage: node --no-warnings scripts/move-by-ids.ts [options] <email-id> [email-id...]

Move one or more emails to a specific mailbox.

Arguments:
  <email-id>              Email ID(s) to move

Options:
  --mailbox <name>    Target mailbox name (required)
  --help              Show this help message

Examples:
  node scripts/move-by-ids.ts --mailbox "Archive" "StrgucNsyw-3"
  node scripts/move-by-ids.ts --mailbox "Processed" "id1" "id2" "id3"
`);
  process.exit(values.help ? 0 : 1);
}

const targetMailbox = values.mailbox as string;
const emailIds = positionals;

const jam = createJamClient();
const accountId = await getAccountId(jam);

// Get target mailbox ID
const [mailboxQuery] = await jam.api.Mailbox.query({
  accountId,
  filter: { name: targetMailbox },
// @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
}, JMAP_OPTIONS);

if (mailboxQuery.ids.length === 0) {
  console.error(`Mailbox "${targetMailbox}" not found`);
  process.exit(1);
}

const mailboxId = mailboxQuery.ids[0];

// Move emails
const moveUpdates: any = {};
for (const emailId of emailIds) {
  moveUpdates[emailId] = {
    mailboxIds: { [mailboxId]: true }
  };
}

console.log(`Moving ${emailIds.length} email(s) to ${targetMailbox}...`);

const [moveResult] = await jam.api.Email.set({
  accountId,
  update: moveUpdates,
// @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
}, JMAP_OPTIONS);

const movedCount = Object.keys(moveResult.updated || {}).length;
console.log(`Successfully moved ${movedCount} emails to ${targetMailbox}`);

if (moveResult.notUpdated && Object.keys(moveResult.notUpdated).length > 0) {
  console.log(`\nFailed to move ${Object.keys(moveResult.notUpdated).length} emails:`);
  for (const [id, error] of Object.entries(moveResult.notUpdated)) {
    console.log(`- ${id}: ${JSON.stringify(error)}`);
  }
}

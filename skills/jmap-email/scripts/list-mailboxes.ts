import { parseArgs } from "node:util";
import { createJamClient, getAccountId, JMAP_OPTIONS } from "./utils/jmap-client.ts";

const { values } = parseArgs({
  options: {
    help: {
      type: "boolean",
    },
  },
  allowPositionals: false,
});

if (values.help) {
  console.log(`
Usage: node --no-warnings scripts/list-mailboxes.ts [options]

Display mailbox hierarchy with unread and total email counts.

Options:
  --help               Show this help message

Examples:
  # View all mailboxes
  node scripts/list-mailboxes.ts
`);
  process.exit(0);
}

const jam = createJamClient();
const accountId = await getAccountId(jam);

const [result] = await jam.api.Mailbox.get({
  accountId,
// @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
}, JMAP_OPTIONS);

console.log("Mailboxes:");
console.log("----------");

const mailboxMap = new Map(result.list.map(m => [m.id, m]));

for (const mailbox of result.list.filter(m => !m.parentId)) {
  printMailbox(mailbox, 0, mailboxMap);
}

function printMailbox(mailbox: any, level: number, map: Map<string, any>) {
  const indent = "  ".repeat(level);
  const unread = mailbox.unreadEmails || 0;
  const total = mailbox.totalEmails || 0;
  const badge = unread > 0 ? ` (${unread} unread)` : "";

  console.log(`${indent}${mailbox.name}${badge} - ${total} total`);

  for (const child of result.list.filter(m => m.parentId === mailbox.id)) {
    printMailbox(child, level + 1, map);
  }
}

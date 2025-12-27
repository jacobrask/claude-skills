import { parseArgs } from "node:util";
import { printEmailList } from "./utils/format-email.ts";
import {
  createJamClient,
  getAccountId,
  JMAP_OPTIONS,
} from "./utils/jmap-client.ts";

const { values } = parseArgs({
  options: {
    limit: {
      type: "string",
      default: "10",
    },
    unread: {
      type: "boolean",
    },
    flagged: {
      type: "boolean",
    },
    mailbox: {
      type: "string",
    },
    from: {
      type: "string",
    },
    help: {
      type: "boolean",
    },
  },
});

if (values.help) {
  console.log(`
Usage: node --no-warnings scripts/list-emails.ts [options]

List recent emails with various filters.

Options:
  --limit <n>        Number of emails to show (default: 10)
  --unread           Show only unread emails
  --flagged          Show only flagged/starred emails
  --mailbox <name>   Filter by mailbox name
  --from <email>     Filter by sender email address
  --help             Show this help message

Examples:
  node scripts/list-emails.ts
  node scripts/list-emails.ts --unread
  node scripts/list-emails.ts --flagged
  node scripts/list-emails.ts --mailbox "Archive"
  node scripts/list-emails.ts --flagged --unread
  node scripts/list-emails.ts --unread --limit 50
  node scripts/list-emails.ts --from "sender@example.com"
`);
  process.exit(0);
}

const limit = parseInt(values.limit, 10);
const unreadOnly = values.unread;
const flaggedOnly = values.flagged;
const mailboxName = values.mailbox;
const fromFilter = values.from;

const jam = createJamClient();
const accountId = await getAccountId(jam);

const filter: Record<string, string> = {};

if (unreadOnly) {
  filter.notKeyword = "$seen";
}

if (flaggedOnly) {
  filter.hasKeyword = "$flagged";
}

if (mailboxName) {
  const [mailboxResult] = await jam.api.Mailbox.query(
    {
      accountId,
      filter: { name: mailboxName },
    },
    // @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
    JMAP_OPTIONS
  );

  if (mailboxResult.ids.length === 0) {
    console.error(`Mailbox "${mailboxName}" not found`);
    process.exit(1);
  }

  filter.inMailbox = mailboxResult.ids[0];
}

if (fromFilter) {
  filter.from = fromFilter;
}

const [queryResult] = await jam.api.Email.query(
  {
    accountId,
    filter: Object.keys(filter).length > 0 ? filter : undefined,
    sort: [{ property: "receivedAt", isAscending: false }],
    limit,
  },
  // @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
  JMAP_OPTIONS
);

if (queryResult.ids.length === 0) {
  console.log("No emails found");
  process.exit(0);
}

const [result] = await jam.api.Email.get(
  {
    accountId,
    ids: queryResult.ids,
    properties: [
      "id",
      "subject",
      "from",
      "to",
      "receivedAt",
      "preview",
      "keywords",
    ],
  },
  // @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
  JMAP_OPTIONS
);

// Build filter description
const filterDesc = [];
if (unreadOnly) filterDesc.push("unread");
if (flaggedOnly) filterDesc.push("flagged");
if (mailboxName) filterDesc.push(`in "${mailboxName}"`);
if (fromFilter) filterDesc.push(`from "${fromFilter}"`);
const title =
  filterDesc.length > 0
    ? `Found ${result.list.length} email(s) (${filterDesc.join(", ")})`
    : `Found ${result.list.length} email(s)`;

printEmailList(result.list, title);

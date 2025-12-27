import { parseArgs } from "node:util";
import { printEmailList } from "./utils/format-email.ts";
import {
  createJamClient,
  getAccountId,
  JMAP_OPTIONS,
} from "./utils/jmap-client.ts";

const { values, positionals } = parseArgs({
  options: {
    mailbox: {
      type: "string",
      default: "Inbox",
    },
    limit: {
      type: "string",
      default: "50",
    },
    help: {
      type: "boolean",
    },
  },
  allowPositionals: true,
});

if (values.help || positionals.length === 0) {
  console.log(`
Usage: node --no-warnings scripts/search-keywords.ts [options] <keyword1> [keyword2] ...

Search for emails matching any of the provided keywords.

Options:
  --mailbox <name>     Mailbox to search (default: "Inbox")
  --limit <number>     Max results (default: 50)
  --help               Show this help message

Examples:
  # Search for receipt-related emails
  node scripts/search-keywords.ts "invoice" "receipt" "order confirmation"

  # Search in different mailbox with custom limit
  node scripts/search-keywords.ts --mailbox "Archive" --limit 10 "meeting" "agenda"

Note: This script shows email previews. Use get-email.ts with an email ID to view full content.
`);
  process.exit(values.help ? 0 : 1);
}

const keywords = positionals;
const limit = parseInt(values.limit, 10);

const jam = createJamClient();
const accountId = await getAccountId(jam);

const [mailboxQuery] = await jam.api.Mailbox.query(
  {
    accountId,
    filter: { name: values.mailbox },
  },
  // @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
  JMAP_OPTIONS
);

if (mailboxQuery.ids.length === 0) {
  console.error(`Mailbox "${values.mailbox}" not found`);
  process.exit(1);
}

const mailboxId = mailboxQuery.ids[0];

const filter = {
  operator: "OR",
  conditions: keywords.map((keyword) => ({
    inMailbox: mailboxId,
    text: keyword,
  })),
};

const [searchResult] = await jam.api.Email.query(
  {
    accountId,
    filter,
    sort: [{ property: "receivedAt", isAscending: false }],
    limit,
  },
  // @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
  JMAP_OPTIONS
);

if (searchResult.ids.length === 0) {
  console.log(`No emails found matching keywords: ${keywords.join(", ")}`);
  process.exit(0);
}

const [result] = await jam.api.Email.get(
  {
    accountId,
    ids: searchResult.ids,
    properties: [
      "id",
      "subject",
      "from",
      "receivedAt",
      "preview",
      "keywords",
    ],
  },
  // @ts-ignore - jmap-jam ProxyAPI types don't expose options param (runtime supports it)
  JMAP_OPTIONS
);

printEmailList(
  result.list,
  `Found ${result.list.length} emails matching: ${keywords.join(", ")}`
);

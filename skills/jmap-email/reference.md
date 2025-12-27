# JMAP API Reference

Complete reference for jmap-jam library methods and JMAP email properties.

## Contents
- Email Properties
- Email.query (Search)
- Email.get (Retrieve)
- Email.set (Update)
- Thread.get
- Mailbox.get
- Mailbox.query
- Blob Operations

## Email Properties

When using `Email.get`, request only the properties you need:

**Identifiers**:
- `id` - Email ID
- `blobId` - Reference to raw RFC 5322 message
- `threadId` - Thread identifier
- `messageId` - RFC 5322 Message-ID header

**Mailbox & Keywords**:
- `mailboxIds` - Object mapping mailbox IDs to true
- `keywords` - Object with keywords like `$seen`, `$flagged`, `$draft`

**Metadata**:
- `size` - Size in bytes
- `receivedAt` - ISO datetime when received
- `sentAt` - ISO datetime from headers

**Headers**:
- `headers` - All headers as array of objects
- `inReplyTo` - Message-IDs this replies to
- `references` - Message-IDs in thread chain

**Addresses**:
- `sender` - Single address object
- `from` - Array of address objects
- `to` - Array of address objects
- `cc` - Array of address objects
- `bcc` - Array of address objects
- `replyTo` - Array of address objects

**Subject & Preview**:
- `subject` - Email subject line
- `preview` - First ~256 characters of text

**Body Structure**:
- `bodyStructure` - MIME tree structure
- `bodyValues` - Map of partId to body content
- `textBody` - Array of text body parts
- `htmlBody` - Array of HTML body parts

**Attachments**:
- `attachments` - Array of attachment metadata
- `hasAttachment` - Boolean

## Email.query (Search)

Search for emails matching criteria.

**Parameters**:
```typescript
{
  accountId: string,
  filter?: EmailFilterCondition,
  sort?: Array<{property: string, isAscending?: boolean}>,
  position?: number,  // Offset for pagination
  limit?: number,     // Max results (default varies by server)
}
```

**Filter Conditions**:
- `from: string` - Sender email or name
- `to: string` - Recipient email or name
- `subject: string` - Text in subject
- `text: string` - Text anywhere in email
- `body: string` - Text in email body
- `before: string` - ISO datetime, received before
- `after: string` - ISO datetime, received after
- `hasKeyword: string` - Has keyword (e.g., `"$seen"`)
- `notKeyword: string` - Lacks keyword (e.g., `"$draft"`)
- `inMailbox: string` - In specific mailbox ID
- `allInThreadHaveKeyword: string` - All emails in thread have keyword
- `someInThreadHaveKeyword: string` - At least one email in thread has keyword

**Returns**:
```typescript
{
  ids: string[],           // Email IDs matching query
  position: number,        // Position in full result set
  total: number,          // Total matching emails
}
```

## Email.get (Retrieve)

Get email details by ID.

**Parameters**:
```typescript
{
  accountId: string,
  ids: string[],                    // Email IDs to fetch
  properties?: string[],             // Specific properties to return
}
```

**Returns**:
```typescript
{
  list: Email[],          // Emails with requested properties
  notFound: string[],     // IDs not found
}
```

## Email.set (Update)

Modify emails (keywords, mailboxIds) or delete.

**Parameters**:
```typescript
{
  accountId: string,
  update?: {
    [emailId: string]: {
      keywords?: {[keyword: string]: boolean},
      mailboxIds?: {[mailboxId: string]: boolean},
    }
  },
  destroy?: string[],  // Email IDs to delete
}
```

**Common Keywords**:
- `$seen` - Mark as read/unread
- `$flagged` - Star/unstar
- `$draft` - Mark as draft
- `$answered` - Mark as replied to

**Returns**:
```typescript
{
  updated: {[emailId: string]: Email},     // Successfully updated
  notUpdated: {[emailId: string]: error},  // Failed updates
  destroyed: string[],                     // Successfully deleted
  notDestroyed: {[emailId: string]: error} // Failed deletions
}
```

## Thread.get

Get email thread details.

**Parameters**:
```typescript
{
  accountId: string,
  ids: string[],  // Thread IDs
}
```

**Returns**:
```typescript
{
  list: Thread[],     // Thread objects with emailIds arrays
  notFound: string[], // Thread IDs not found
}
```

## Mailbox.get

List mailboxes/folders.

**Parameters**:
```typescript
{
  accountId: string,
  ids?: string[],        // Specific mailbox IDs (optional)
  properties?: string[], // Specific properties (optional)
}
```

**Mailbox Properties**:
- `id` - Mailbox ID
- `name` - Display name
- `parentId` - Parent mailbox ID (null for top-level)
- `role` - Standard role (`inbox`, `trash`, `sent`, etc.)
- `totalEmails` - Total email count
- `unreadEmails` - Unread email count
- `totalThreads` - Total thread count
- `unreadThreads` - Unread thread count

**Returns**:
```typescript
{
  list: Mailbox[],
  notFound: string[],
}
```

## Mailbox.query

Search for mailboxes.

**Parameters**:
```typescript
{
  accountId: string,
  filter?: {
    parentId?: string | null,  // Filter by parent
    hasRole?: string,          // Filter by role
    name?: string,             // Name contains text
  },
  sort?: Array<{property: string, isAscending?: boolean}>,
}
```

**Returns**:
```typescript
{
  ids: string[],  // Mailbox IDs matching query
}
```

## Blob Operations

### downloadBlob

Download binary blob (raw email, attachment, etc.).

**Parameters**:
```typescript
{
  accountId: string,
  blobId: string,       // Blob identifier
  mimeType: string,     // Expected MIME type
  fileName: string,     // Filename for download
}
```

**Returns**: `Promise<Response>` (Fetch API Response object)

Use `.arrayBuffer()`, `.blob()`, or `.text()` to read content.

### uploadBlob

Upload binary data.

**Parameters**:
```typescript
(accountId: string, blob: Blob)
```

**Returns**:
```typescript
Promise<{
  accountId: string,
  blobId: string,   // Server-assigned blob ID
  type: string,     // MIME type
  size: number,     // Bytes
}>
```

## JMAP Core Capability

Most methods automatically include required capabilities. For explicit control:

```typescript
const options = { using: ["urn:ietf:params:jmap:core"] };
const [result] = await jam.api.Email.get(args, options);
```

**Standard Capabilities**:
- `urn:ietf:params:jmap:core` - Core JMAP
- `urn:ietf:params:jmap:mail` - Email operations
- `urn:ietf:params:jmap:submission` - Email sending (if supported)

## Error Handling

Check for errors in responses:

```typescript
const [result] = await jam.api.Email.get({...});

if (result.notFound && result.notFound.length > 0) {
  console.error(`Not found: ${result.notFound.join(", ")}`);
}
```

For update/delete operations, check `notUpdated` and `notDestroyed`.

## References

- [jmap-jam GitHub](https://github.com/htunnicliff/jmap-jam)
- [JMAP Core RFC 8620](https://datatracker.ietf.org/doc/html/rfc8620)
- [JMAP Mail RFC 8621](https://datatracker.ietf.org/doc/html/rfc8621)

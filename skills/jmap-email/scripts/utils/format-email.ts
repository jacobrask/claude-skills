/**
 * Utilities for consistent email formatting across scripts
 */

export interface EmailAddress {
  name?: string;
  email: string;
}

export interface Email {
  id?: string;
  subject?: string;
  from?: EmailAddress[];
  to?: EmailAddress[];
  cc?: EmailAddress[];
  receivedAt?: string;
  sentAt?: string;
  preview?: string;
  size?: number;
  keywords?: Record<string, boolean>;
  textBody?: any[];
  htmlBody?: any[];
  bodyValues?: Record<string, { value: string }>;
}

/**
 * Format email address with optional name
 */
export function formatAddress(address: EmailAddress): string {
  if (address.name) {
    return `${address.name} <${address.email}>`;
  }
  return address.email;
}

/**
 * Format list of email addresses
 */
export function formatAddresses(addresses: EmailAddress[] | undefined): string {
  if (!addresses || addresses.length === 0) {
    return "(none)";
  }
  return addresses.map(formatAddress).join(", ");
}

/**
 * Format date in readable format
 */
export function formatDate(isoDate: string): string {
  return new Date(isoDate).toLocaleString();
}

/**
 * Format file size in human-readable format
 */
export function formatSize(bytes: number): string {
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(2)} KB`;
  }
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`;
}

/**
 * Print email in compact format (for lists)
 */
export function printEmailCompact(email: Email): void {
  const isUnread = email.keywords && !email.keywords.$seen;
  const isFlagged = email.keywords && email.keywords.$flagged;
  const unreadMarker = isUnread ? "[UNREAD] " : "";
  const flaggedMarker = isFlagged ? "⭐ " : "";

  console.log(`${flaggedMarker}${unreadMarker}${email.subject || "(no subject)"}`);
  console.log(`From: ${formatAddresses(email.from)}`);

  if (email.receivedAt) {
    console.log(`Date: ${formatDate(email.receivedAt)}`);
  }

  if (email.id) {
    console.log(`ID: ${email.id}`);
  }

  if (email.preview) {
    console.log(`Preview: ${email.preview.substring(0, 100)}${email.preview.length > 100 ? "..." : ""}`);
  }
}

/**
 * Print email in detailed format (for single email view)
 */
export function printEmailDetailed(email: Email): void {
  const isUnread = email.keywords && !email.keywords.$seen;
  const isFlagged = email.keywords && email.keywords.$flagged;
  const unreadMarker = isUnread ? "[UNREAD] " : "";
  const flaggedMarker = isFlagged ? "⭐ " : "";

  console.log(`Subject: ${flaggedMarker}${unreadMarker}${email.subject || "(no subject)"}`);
  console.log("From:", formatAddresses(email.from));
  console.log("To:", formatAddresses(email.to));

  if (email.cc && email.cc.length > 0) {
    console.log("Cc:", formatAddresses(email.cc));
  }

  if (email.receivedAt) {
    console.log("Date:", formatDate(email.receivedAt));
  }

  if (email.sentAt) {
    console.log("Sent:", formatDate(email.sentAt));
  }

  if (email.size !== undefined) {
    console.log("Size:", formatSize(email.size));
  }

  if (email.id) {
    console.log("ID:", email.id);
  }

  // Print body if available
  if (email.textBody && email.textBody.length > 0 && email.bodyValues) {
    const partId = email.textBody[0].partId;
    const bodyValue = email.bodyValues[partId];
    if (bodyValue && bodyValue.value) {
      console.log("\n--- Body ---\n");
      console.log(bodyValue.value);
    }
  } else if (email.htmlBody && email.htmlBody.length > 0 && email.bodyValues) {
    const partId = email.htmlBody[0].partId;
    const bodyValue = email.bodyValues[partId];
    if (bodyValue && bodyValue.value) {
      console.log("\n--- HTML Body ---\n");
      console.log(bodyValue.value);
    }
  }
}

/**
 * Print email list with separator
 */
export function printEmailList(emails: readonly Email[], title?: string): void {
  if (title) {
    console.log(title);
  }
  console.log("=".repeat(80));

  for (const email of emails) {
    console.log();
    printEmailCompact(email);
    console.log("-".repeat(80));
  }

  console.log("\nTotal:", emails.length, "emails");
}

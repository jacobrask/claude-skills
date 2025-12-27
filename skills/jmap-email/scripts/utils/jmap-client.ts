import JamClient from "jmap-jam";

/**
 * Create a JMAP client with environment variable validation
 */
export function createJamClient(): JamClient {
  const sessionUrl = process.env.JMAP_SESSION_URL;
  const bearerToken = process.env.JMAP_BEARER_TOKEN;

  if (!sessionUrl || !bearerToken) {
    console.error("ERROR: Missing required JMAP environment variables\n");
    console.error("You need to set these environment variables when launching Claude Code:");
    console.error("  - JMAP_SESSION_URL");
    console.error("  - JMAP_BEARER_TOKEN");
    console.error("Example:");
    console.error('  JMAP_SESSION_URL="https://api.fastmail.com/.well-known/jmap" \\');
    console.error('  JMAP_BEARER_TOKEN="your-token-here" \\');
    console.error("  claude\n");
    process.exit(1);
  }

  return new JamClient({
    sessionUrl,
    bearerToken,
  });
}

/**
 * Get account ID from environment or auto-detect
 */
export async function getAccountId(jam: JamClient): Promise<string> {
  return process.env.JMAP_ACCOUNT_ID || await jam.getPrimaryAccount();
}

/**
 * Standard JMAP options for API calls
 */
export const JMAP_OPTIONS = { using: ["urn:ietf:params:jmap:core"] };

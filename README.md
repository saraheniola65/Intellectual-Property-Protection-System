# Intellectual Property Protection System

A comprehensive blockchain-based system for protecting and managing intellectual property rights using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides five core contracts for different aspects of IP protection:

1. **Patent Application Contract** - Records invention claims and establishes priority dates
2. **Copyright Registration Contract** - Establishes ownership of creative works
3. **Trademark Verification Contract** - Validates brand names and logo rights
4. **Licensing Agreement Contract** - Manages IP usage permissions and royalties
5. **Infringement Detection Contract** - Monitors and reports unauthorized IP usage

## Features

### Patent Application Contract
- Record invention details with priority dates
- Store patent claims and descriptions
- Track application status and approvals
- Immutable timestamp records

### Copyright Registration Contract
- Register creative works with ownership proof
- Store work metadata and creation dates
- Transfer copyright ownership
- Verify authorship claims

### Trademark Verification Contract
- Register brand names and logos
- Verify trademark availability
- Track trademark renewals
- Manage trademark classifications

### Licensing Agreement Contract
- Create licensing agreements between parties
- Define usage terms and royalty rates
- Track license payments and renewals
- Enforce licensing restrictions

### Infringement Detection Contract
- Report suspected IP infringement
- Track infringement cases
- Store evidence and documentation
- Manage dispute resolution

## Contract Architecture

Each contract is designed to be independent and self-contained:

- **No cross-contract dependencies** - Each contract operates independently
- **Immutable records** - All IP registrations are permanently stored
- **Owner-controlled** - Only authorized parties can modify their IP records
- **Transparent verification** - Public functions for verifying IP ownership

## Data Structures

### Patent Application
\`\`\`clarity
{
inventor: principal,
title: (string-ascii 200),
description: (string-ascii 1000),
claims: (string-ascii 2000),
priority-date: uint,
status: (string-ascii 50),
approved: bool
}
\`\`\`

### Copyright Registration
\`\`\`clarity
{
owner: principal,
title: (string-ascii 200),
work-type: (string-ascii 50),
creation-date: uint,
description: (string-ascii 1000),
hash: (buff 32)
}
\`\`\`

### Trademark
\`\`\`clarity
{
owner: principal,
name: (string-ascii 100),
classification: (string-ascii 50),
registration-date: uint,
renewal-date: uint,
active: bool
}
\`\`\`

### License Agreement
\`\`\`clarity
{
licensor: principal,
licensee: principal,
ip-type: (string-ascii 50),
ip-id: uint,
terms: (string-ascii 500),
royalty-rate: uint,
start-date: uint,
end-date: uint,
active: bool
}
\`\`\`

### Infringement Case
\`\`\`clarity
{
reporter: principal,
accused: principal,
ip-type: (string-ascii 50),
ip-id: uint,
evidence: (string-ascii 1000),
report-date: uint,
status: (string-ascii 50)
}
\`\`\`

## Usage Examples

### Register a Patent
\`\`\`clarity
(contract-call? .patent-application apply-patent
"Revolutionary Blockchain Algorithm"
"A novel consensus mechanism for distributed systems"
"1. A method for achieving consensus... 2. The system comprises..."
)
\`\`\`

### Register Copyright
\`\`\`clarity
(contract-call? .copyright-registration register-copyright
"My Novel"
"literary-work"
"A compelling story about blockchain technology"
0x1234567890abcdef...
)
\`\`\`

### Create License Agreement
\`\`\`clarity
(contract-call? .licensing-agreement create-license
'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7
"patent"
u1
"Non-exclusive license for commercial use"
u500  ;; 5% royalty
u1640995200  ;; Start date
u1672531200  ;; End date
)
\`\`\`

## Security Features

- **Principal-based ownership** - All IP records are tied to Stacks principals
- **Immutable timestamps** - Block height provides tamper-proof dating
- **Access controls** - Only owners can modify their IP records
- **Transparent verification** - Anyone can verify IP ownership and status

## Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
npm test
\`\`\`

Tests cover:
- Contract deployment and initialization
- IP registration workflows
- Ownership verification
- License management
- Infringement reporting
- Error handling and edge cases

## Deployment

1. Install dependencies: \`npm install\`
2. Configure Clarinet: Edit \`Clarinet.toml\` with your settings
3. Deploy contracts: \`clarinet deploy\`
4. Run tests: \`npm test\`

## License

This project is licensed under the MIT License.

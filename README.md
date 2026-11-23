# Agentforce Proactive Contract Renewal & Sales Agent

An intelligent Salesforce Agentforce solution designed to help Sales Representatives proactively manage contract renewals, identify customer churn risks, automate follow-ups, generate personalized renewal communications, and manage approval workflows.

## Overview

The Proactive Contract Renewal Agent assists Sales Representatives in managing renewal opportunities by analyzing customer engagement, contract expiration dates, account health, customer satisfaction and support activity.

It evaluates renewal risks, prioritizes opportunities requiring attention, generates personalized renewal email drafts, creates follow-up tasks and facilitates Salesforce approval workflows.

The Agent is also integrated with Slack to support approval notifications and Salesforce-related interactions directly within the workspace.

## Key Capabilities

### 1. Renewal Opportunity Analysis
- Identifies open renewal opportunities approaching their contract expiration dates.
- Evaluates customer engagement using Last Activity Date.
- Considers CSAT scores, open support cases and account health.
- Categorizes renewal opportunities based on urgency.
- Recommends appropriate customer engagement strategies.

### 2. Personalized Email Draft Generation
- Generates renewal outreach emails using Salesforce Prompt Builder.
- Supports URGENT and NURTURING email templates.
- Generates standalone and opportunity-specific email drafts.
- Uses Opportunity, Account and customer context to personalize communications.
- Allows users to review and save email drafts against Opportunity records.
- Supports bulk email draft generation for multiple renewal opportunities.

**Note:** The Agent generates and saves drafts; it does not automatically send customer emails.

### 3. Automated Task Management
- Creates follow-up tasks based on user requirements.
- Associates tasks with relevant Opportunities or Accounts.
- Supports task assignment to specified Salesforce users.
- Associates relevant Contacts whenever available.
- Helps Opportunity owners track renewal activities.

### 4. Approval Management
- Identifies pending Salesforce approval requests.
- Retrieves associated approval work items.
- Supports approval and rejection requests.
- Captures comments and returns processing results.
- Uses Salesforce's native Approval Process engine.

Approval operations remain subject to Salesforce approval authorization.

### 5. Slack Integration
- Retrieves Salesforce record and approval information.
- Identifies assigned approvers and their Slack Member IDs.
- Sends approval notifications through Slack Direct Messages.
- Constructs approval links for pending approval work items.
- Supports Slack channel creation and Agent-based conversations.
- Allows authorized users to initiate approval actions through the Agent.

## Agent Architecture

The solution combines Agentforce reasoning, Salesforce data retrieval, Apex business logic, Prompt Builder and Slack integration.

```text
Sales Representative
        |
        v
Proactive Renewal Agent
        |
        +---------------------------+
        |                           |
        v                           v
Renewal Analysis              Record Identification
        |                           |
        v                           v
Opportunity & Account         Salesforce Data Retrieval
Health Evaluation                   |
        |                           |
        v                           v
Email Draft Generation        Task Management
        |                           |
        v                           |
Save Email Draft                   |
        |                           |
        +-------------+-------------+
                      |
                      v
               Approval Management
                      |
             +--------+--------+
             |                 |
             v                 v
       Salesforce          Slack Integration
       Approval            Notifications
       Processes
```

## Apex Invocable Actions

The following Apex components implement the Agent's custom business operations.

| Apex Class | Responsibility |
|---|---|
| `generateMailForOpportnuityRenewal` | Identifies renewal opportunities using contract expiration and inactivity criteria, then generates email drafts based on the specified template type. |
| `createTaskWithAllParmetersInvocable` | Creates Salesforce Tasks using user-provided requirements and task parameters. |
| `AiJobRunTriggerhandler` | Handles bulk email generation through AIJobRun and Salesforce Prompt Builder. |
| `Test_Email_Draft_sample` | Generates standalone email drafts using details supplied by the Agent. |
| `generateMailforRequestedOpp` | Generates and optionally saves a renewal email draft for a specific Opportunity. |
| `postAIGeneratedChatterMessage` | Posts Chatter notifications summarizing renewal risk and linking generated email drafts. |
| `approveRequestInvocableAction` | Processes approval or rejection requests using Salesforce's native Approval Process functionality. |

## Renewal Prioritization

The Agent evaluates contract expiration dates to determine the appropriate renewal outreach priority.

| Contract Expiration | Priority | Email Template |
|---|---|---|
| Within 30 days | URGENT | Urgent Renewal |
| 31–60 days | NURTURING | Renewal Nurturing |

Additional signals such as customer engagement, CSAT scores and open Cases contribute to renewal risk assessment.

## Technology Stack

- Salesforce Agentforce
- Salesforce Apex
- Salesforce Standard Assets
- Salesforce Prompt Builder
- Salesforce Approval Processes
- Salesforce CRM (Accounts, Opportunities, Contracts, Tasks and Cases)
- Salesforce Chatter
- Slack Integration
- Salesforce DX / VS Code
- Git and GitHub

## Repository Structure

```text
agentforce-sales-agent/
│
├── force-app/
│   └── main/
│       └── default/
│           ├── aiAuthoringBundles/
│           ├── aiAgents/
│           ├── aiAgentDefinitionVersions/
│           ├── classes/
│           ├── flows/
│           ├── prompts/
│           ├── objects/
│           └── permissionsets/
│
├── docs/
│   ├── architecture.md
│   ├── agent-instructions.md
│   ├── actions.md
│   ├── workflows.md
│   └── deployment.md
│
├── manifest/
│   └── package.xml
│
├── scripts/
│
├── .github/
│   └── workflows/
│
├── sfdx-project.json
├── .gitignore
└── README.md
```

*The metadata folders shown are illustrative. Actual folders depend on the retrieved Salesforce metadata and API version.*

## Getting Started

### Prerequisites

- Salesforce Developer Org with Agentforce enabled.
- Salesforce CLI.
- Visual Studio Code.
- Salesforce Extension Pack.
- Git and GitHub.

### Setup

1. Clone the repository.

```bash
git clone YOUR_REPOSITORY_URL
```

2. Open the project in VS Code.

```bash
cd agentforce-sales-agent
code .
```

3. Authorize your Salesforce Org.

```bash
sf org login web --alias SalesAgentDev
```

4. Deploy the Salesforce metadata.

```bash
sf project deploy start --target-org SalesAgentDev
```

5. Run Apex tests and validate the deployment.

6. Configure environment-specific integrations and permissions.

7. Verify and activate the Agent in the target org.

Refer to `docs/deployment.md` for the complete deployment procedure.

## Project Objective

The objective of this project is to demonstrate how Salesforce Agentforce can be integrated with existing CRM processes to deliver intelligent sales assistance, proactive renewal management, automated business operations and cross-platform collaboration.

The solution aims to improve renewal visibility, reduce manual sales activities, streamline approval processes and help Sales Representatives make informed customer engagement decisions.

---

**Built with Salesforce Agentforce | Apex | Prompt Builder | Slack**

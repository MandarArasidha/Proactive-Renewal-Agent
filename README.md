<<<<<<< HEAD
# Salesforce DX Project

Salesforce DX is a development approach that brings source-driven development, team collaboration, and continuous integration to the Salesforce Platform. Instead of working directly in an org through a web browser, you work with metadata as source files in a local DX project, track changes in version control, and deploy through automated processes.

This project template gets you started with the tools and structure you need to build Salesforce applications using source control, scratch orgs, and the Salesforce CLI.

## Prerequisites

Before you start, make sure you have:

- **Salesforce CLI** - Download from [developer.salesforce.com/tools/salesforcecli](https://developer.salesforce.com/tools/salesforcecli). See [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for details.
- **VS Code with Salesforce Extension Pack** - See [Installation Instructions](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html) for details. Includes the Agentforce Vibes extension.
- **A development org** - Sign up for a free Developer Edition org [here](https://developer.salesforce.com/signup).
- **Dev Hub enabled** (optional, required to create scratch orgs) - You can enable Dev Hub in your development org under Setup > Dev Hub.  See [Provide Developers Access to Salesforce DX Tools](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_setup_dx_tools.htm).

## Project Structure

Your DX project follows this structure:

- **`force-app/main/default/`** - Your metadata source files live in this default package directory. You can configure additional package directories in the `sfdx-project.json` file.
- **`config/`** - Scratch org definitions and project settings
- **`scripts/`** - Automation scripts for common tasks
- **`sfdx-project.json`** - Project manifest that defines package directories, namespace, API version, and other project-level settings

See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm).

## Get Started

Ready to start developing? The [Get Started with Salesforce DX](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_get_started_dx.htm) guide walks you through your first project, from creating a scratch org to creating a simple Apex class or LWC to deploying your code to a sandbox.

## Common Salesforce CLI Commands

Here are common CLI commands that you'll use the most:

- `sf org login web`: Authorize an org
- `sf org open`: Open your org in a browser
- `sf org create scratch`: Create a scratch org
- `sf project deploy start`: Deploy metadata to your org
- `sf project retrieve start`: Retrieve metadata from your org
- `sf template generate <artifact>`: Scaffold new components, such as Apex classes and triggers, LWC components, Lightning apps, and more
- `sf apex <command>`: Run Apex tests, run anonymous Apex blocks, and view logs
- `sf data <command>`: Work with test data
- `sf alias <command>`: Manage org aliases
- `sf config <command>`: Configure CLI settings

## Use Agentforce Vibes to Build Lightning Apps

Transform your ideas into custom Lightning apps that extend CRM workflows directly in Lightning Experience. Through natural conversations with Agentforce Vibes, implement custom objects and fields, complex business logic, and dynamic UI components. See [Build a Lightning App Using Agentforce Vibes](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/lexapp-overview.html).

## Additional Resources

- [Agentforce Vibes Developer Guide](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/einstein-overview.html)
- [Salesforce CLI Installation Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce CLI Plugin Development Guide](https://developer.salesforce.com/docs/platform/salesforce-cli-plugin/guide/conceptual-overview.html)
- [Salesforce VS Code Extensions Documentation](https://developer.salesforce.com/tools/vscode/)

=======
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
>>>>>>> 69198db093d7e5466fefe8a8ee01c160d25c0da8

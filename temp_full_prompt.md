<USER_REQUEST>
# MASTER DEVELOPMENT PROMPT — FIX, ENHANCE, AND VERIFY THE ENTIRE APPLICATION

You are a senior full-stack engineer, software architect, UI/UX engineer, and QA specialist working on my existing application through Antigravity.

Your task is to inspect the existing project, identify the root causes of the reported bugs, implement all requested changes, and verify that they work correctly in the actual application.

**Do not just provide recommendations, mockups, sample code, or a plan. Make the changes directly in the existing project.**

Preserve the existing application architecture, design system, authentication, permissions, database structure, and working features wherever possible. Do not rebuild the application unnecessarily.

## 1. First inspect the existing project

Before modifying anything:

- Identify the frontend framework, backend framework, database, authentication system, routing, and existing UI component library.
- Inspect the global search implementation, notification system, locker/vault assignment logic, branch-specific data models, and existing user/admin dashboards.
- Identify the current database schema, API endpoints, real-time event mechanisms, and permission checks.
- Inspect the existing AI integrations, if any, and the QR-related functionality.
- Reproduce each reported bug and identify its actual root cause.
- Check for duplicated logic, incorrect default values, hardcoded demo data, stale cached data, incorrect database queries, and frontend/backend state mismatches.

Create a concise internal implementation checklist and then proceed with the changes. Do not stop after creating the checklist.

# 2. Fix and enhance Global Search

The global search bar must allow administrators to search for any relevant information or entity available within the application that their permissions allow them to access.

### Required functionality

1. Search across relevant application modules, such as:
   - Users and user profiles.
   - Administrators and staff, where permitted.
   - Locker/vault records and assignments.
   - Branches and branch-specific records.
   - Notifications and relevant notification records.
   - Other existing application modules, records, and searchable content.
2. Discover the application's actual modules and searchable entities from the codebase. Do not limit search to the examples above.
3. Completely remove **Core Library Services** from the global search bar's searchable entities, suggestions, results, and search index, wherever applicable.
4. Do not remove or break the Core Library Services module itself unless explicitly required. Exclude it from global search only.
5. Return results that accurately correspond to the administrator's actual query.
6. Show the correct entity name, relevant details, category, and destination link for every result.
7. Clicking a result must open the correct record or application page.
8. Never show unrelated results, incorrectly labeled entities, fabricated records, or results belonging to another branch without appropriate authorization.
9. Display useful loading, empty-result, error, and retry states.
10. Support case-insensitive searches, partial matches, trimmed input, and sensible matching for names, identifiers, and other relevant fields.
11. Debounce requests where appropriate, cancel outdated requests, and prevent older responses from overwriting newer search results.
12. Handle keyboard navigation, Enter, Escape, and accessible focus behavior where appropriate.
13. Respect role-based access control and branch-level data isolation.

### Search result accuracy

The query, backend search parameters, returned records, displayed result labels, and navigation destinations must remain consistent.

For example, if an administrator searches for a specific user or locker identifier, the results must correspond to that search rather than showing unrelated default, cached, or demo results.

Implement proper server-side filtering and pagination where necessary. Do not download the entire database into the browser just to perform global search.

### Acceptance criteria

- Searching for a known record returns the correct record.
- Searching for a nonexistent record displays a genuine empty state.
- Rapidly changing search terms does not display stale results.
- Core Library Services never appears in global search results or suggestions.
- Users cannot access records outside their permissions through search.
- Selecting a result opens the correct page and record.

# 3. Fix the Notification System Completely

The notification system must display genuine application notifications and support every notification action correctly.

## A. Remove all green notification dots

- Remove the green dot or green status indicator from the notification button.
- Remove unwanted green dots from every location within the notification section, including notification items, headers, badges, and related components.
- Search the entire codebase for the components and styles responsible for these indicators.
- Do not introduce another colored dot or decorative status indicator as a replacement.
- Preserve legitimate unread counts or other useful information if the application already supports them.

## B. Eliminate demo notifications

- Remove all hardcoded, mock, sample, placeholder, and demo notifications from production-facing application screens.
- Do not generate fake notifications merely to populate the interface.
- Identify and remove development fixtures from production data sources without deleting genuine user data.
- Empty notification lists must display a clean, informative empty state.

## C. Make real notifications work end to end

Inspect and repair the complete notification lifecycle:

1. Identify the events that should generate notifications in the existing application.
2. Generate a notification when a genuine, configured application event occurs.
3. Persist notifications in the appropriate database or existing notification storage system.
4. Associate each notification with the correct recipient, event, timestamp, entity, and branch when applicable.
5. Retrieve notifications from the actual data source.
6. Display newly received notifications in the notification section.
7. Use the existing real-time mechanism, such as WebSockets, server-sent events, or the project's current subscription system, if available and appropriate.
8. Otherwise, implement a suitable refresh strategy without creating excessive requests.
9. Maintain notification state across page navigation and browser refreshes.
10. Ensure notifications are not duplicated when events are retried or subscriptions reconnect.

Only display notifications that genuinely exist or are generated by real application events. Do not create artificial activity simply to make the interface look populated.

## D. Implement and verify all notification actions

Every visible notification control must perform its intended operation.

Required actions include:

- Mark a notification as read.
- Mark a notification as unread, if supported by the existing design.
- Mark all notifications as read.
- Open the related record or page.
- Delete or dismiss a notification, if the existing product supports that action.
- Refresh or retrieve notifications, if a refresh control exists.
- Update unread counts and notification state immediately and consistently.

### Data consistency requirements

- Persist actions to the backend rather than changing only frontend state.
- Update the UI optimistically where appropriate, with rollback and error feedback if the request fails.
- Recalculate unread counts correctly after every operation.
- Ensure that marking one notification as read does not accidentally mark other notifications as read.
- Ensure mark-all-as-read affects only the authenticated user's authorized notifications.
- Prevent duplicate actions and handle network failures gracefully.
- Preserve state after a reload and across sessions according to the application's existing persistence rules.
- Enforce notification ownership and authorization on the server.

### Acceptance criteria

Generate a notification through a genuine application event and verify that it appears for the correct recipient. Test every notification button and verify its persisted result in the database or actual notification API.

# 4. Fix the Locker/Vault Assignment Bug in Both Branches

There is a critical bug: lockers are displayed as assigned even when no user has been assigned to them.

Fix this at the data-model, backend, and frontend levels. Apply the fix consistently to both existing branches.

## A. Establish a single source of truth

Inspect the actual locker/vault schema and assignment workflow.

Determine assignment status using the application's authoritative assignment data, not a hardcoded default, stale frontend variable, unrelated user record, or incorrect branch-level count.

The fundamental rule is:

- A locker with no valid active assignment must display **Unassigned**.
- A locker with a valid active assignment to a user must display **Assigned**.
- An assignment that has been removed, revoked, or ended must no longer make the locker appear assigned.
- If assignment history is retained, historical assignments must not be mistaken for active assignments.
- Invalid or orphaned assignment references must not silently mark a locker as assigned.

Use the existing data model and assignment rules. If an explicit assignment status is stored, ensure that it remains consistent with the authoritative assignment record and does not override reality.

## B. Fix branch isolation

Apply the same corrected assignment logic to both branches.

- Every locker must be evaluated against the correct branch and its valid assignment records.
- Assigning a user to a locker in one branch must not change assignment status in the other branch.
- A locker in Branch A must not be marked assigned because a similarly identified locker or user exists in Branch B.
- If the application uses shared tables, enforce the appropriate branch identifiers and relational constraints in queries and mutations.
- Do not duplicate the implementation in a way that causes branch-specific behavior to diverge.

## C. Correct the assignment workflow

When an authorized administrator assigns a locker:

1. Validate the locker and user.
2. Verify that both belong to the appropriate branch and satisfy existing business rules.
3. Create or update the authoritative assignment record.
4. Persist the change.
5. Refresh or invalidate affected cached data.
6. Update the UI to show Assigned only after the operation succeeds.
7. Display a useful success or error message.

When an assignment is removed, update the authoritative record and immediately reflect the correct status.

Prevent conflicting assignments if the existing business rules require a locker to have only one active user.

## D. Data migration and safety

Inspect existing records to identify inconsistent assignment states.

Do not blindly reset every locker to Unassigned. Reconcile status against valid assignment records. If a migration or cleanup is required, make it reversible where practical and preserve legitimate assignment history.

### Acceptance tests

Test both branches independently:

- New locker with no assignment: Unassigned.
- Existing locker with no valid active assignment: Unassigned.
- Locker assigned to a valid user: Assigned.
- Assignment removed: Unassigned.
- Locker assigned in Branch A: no unintended status changes in Branch B.
- Failed assignment request: no false Assigned state.
- Reloading the page: correct status remains.
- Switching branches: correct branch-specific assignments appear.

# 5. Add a Gemini-Powered AI Chatbot

Integrate a functional AI chatbot using the Gemini API. The chatbot must be useful to both administrators and regular users while respecting their individual permissions.

Google Cloud project information supplied for this integration:

- Project number: 1047343115021
- Project resource: projects/1047343115021
- Provider: Google Gemini API

The API credential previously supplied in the conversation must be considered exposed. Do not reuse or reproduce it. Use a newly rotated credential stored securely in the server environment.

## A. Secure Gemini integration

- Determine the application's backend architecture and integrate Gemini through the backend or an appropriate secure server-side function.
- Store the new API key in a server-side environment variable such as GEMINI_API_KEY.
- Never expose the key in frontend JavaScript, HTML, browser network configuration, public environment variables, source maps, logs, or committed files.
- Never place credentials in the chat UI or return them in API responses.
- Validate and authorize every chat request.
- Add rate limits, request size limits, appropriate timeouts, and graceful error handling.
- Follow the provider's current API documentation and use a supported Gemini model.
- Use the appropriate official SDK or authenticated API endpoint for the existing runtime.
- Do not assume that a Google Cloud project number alone provides API access. Verify that the required API is enabled, the chosen model is accessible, and billing or quotas are configured where required.
- Do not invent successful authentication or claim the integration works without testing it.

## B. Chatbot capabilities

The chatbot must support natural-language questions from both administrators and users.

Examples include:

- Questions about how to use the application.
- Help navigating application modules.
- Questions about features, workflows, and settings.
- Questions about lockers and assignment workflows.
- Questions about the user's own permitted records.
- Administrative questions about records, summaries, and operational workflows, when authorized.
- Guidance on notifications, QR functionality, and common errors.
- Follow-up questions that use relevant conversation context.
- Clear explanations when information is unavailable.

The assistant should answer in a helpful, conversational way and support reasonable multi-turn conversations.

## C. Connect the chatbot to actual application data

Do not implement a generic Gemini chat window that can only answer general questions.

Where the application already provides relevant APIs or services, implement permission-checked tools or backend functions that let the chatbot retrieve the appropriate live application information.

For example:

- An administrator may ask for authorized branch-specific operational information.
- A user may ask about their own account or permitted locker details.
- A user may ask for help understanding a notification or navigating the application.

The chatbot must retrieve information from the actual application data sources when necessary, rather than guessing or fabricating records.

Security requirements:

- Derive identity, role, and branch access from the authenticated server-side session or token.
- Never trust a role, user ID, branch ID, or permission supplied only by the frontend or natural-language prompt.
- Enforce authorization for every tool call and data query.
- Prevent one user from retrieving another user's private data.
- Prevent unauthorized cross-branch data access.
- Never reveal API keys, secrets, credentials, internal security details, or unauthorized personal information.
- Treat retrieved database content and user messages as untrusted input.
- Require explicit confirmation for consequential actions such as assignments, deletions, or other changes to application data.
- Do not allow the model to bypass normal application permissions or validation.

If the chatbot cannot access a requested piece of information, it should explain the limitation instead of inventing an answer.

## D. Floating chatbot interface

Create a polished, responsive, floating chatbot interface integrated into the existing application design.

### Launcher

- Use the application's existing logo or an appropriate existing app-logo asset as the floating chatbot launcher.
- Position it at the bottom-right corner by default.
- Keep it compact so it does not obstruct application modules.
- Make it visible on desktop and mobile.
- Provide an accessible name, keyboard support, and appropriate focus handling.

### Drag-and-drop behavior

- Allow the user to drag the floating logo to different corners or positions within the visible application viewport.
- Keep the launcher within the viewport at all times.
- Support mouse and touch/pointer interactions.
- Distinguish dragging from clicking so that dragging does not accidentally open the chat window.
- Prevent the drag interaction from interfering with normal scrolling or other controls.
- When practical, retain the user's last position during the current session and restore it safely.

### Inactive appearance

- When the chatbot is inactive or collapsed, reduce the launcher's opacity so the user can see and interact with the application clearly.
- Keep the launcher discoverable and sufficiently visible for accessibility.
- Restore full visibility when the user hovers over it, focuses it, or interacts with it, where appropriate.
- Do not use a permanent overlay that blocks navigation or other application modules.

### Expanded chat window

When the launcher is clicked:

- Open a clean, compact chat panel anchored to the launcher.
- Provide a header, conversation history, message input, send button, loading indicator, and clear error states.
- Support Enter to send and Shift+Enter for a new line where appropriate.
- Display messages distinctly for the user and AI assistant.
- Support scrolling and long responses without breaking the layout.
- Include a close or minimize control.
- Keep the panel within the viewport and adapt its size on smaller screens.
- Handle failed requests, rate limits, empty messages, and network errors gracefully.
- Ensure the chat panel can be closed and reopened without unintended duplicate conversations or requests.

### Acceptance criteria

Verify that the chatbot works with a newly configured server-side Gemini credential, retrieves authorized live data where supported, respects role permissions, handles errors, and can be dragged around the viewport without obstructing normal app usage.

# 6. Add a Universal QR Portal Page for Users

Implement a dedicated Universal QR Portal page for authenticated users.

First inspect the existing QR generation, scanning, validation, and routing functionality. Reuse the existing implementation where appropriate rather than introducing a conflicting QR system.

## Required functionality

- Add a clearly named Universal QR Portal page to the user-facing navigation.
- Use the application's existing routing, styling, authentication, and authorization patterns.
- Allow users to access QR functionality appropriate to their role and permissions.
- If the existing application supports user-specific QR generation, display or generate the appropriate QR code.
- If the application supports scanning, provide a working scanning workflow on compatible devices and browsers.
- Support mobile-responsive layouts.
- Provide loading, empty, invalid QR, expired QR, and error states where relevant.
- Validate QR payloads on the backend before performing sensitive actions.
- Avoid exposing sensitive user information directly in QR payloads.
- Use opaque, signed, or otherwise securely validated identifiers appropriate to the existing architecture.
- Enforce expiry, revocation, replay prevention, and one-time-use validation where the underlying QR workflow requires them.
- Ensure QR access cannot bypass authentication, role permissions, or branch restrictions.
- Provide appropriate fallback instructions when camera permissions are denied or the device does not support scanning.
- Ensure every QR-related button performs its intended action.

Do not fabricate QR operations that the backend cannot support. If a new workflow requires database changes or API endpoints, implement those changes consistently with the existing project.

# 7. Application-Wide Button and Interaction Audit

Audit all buttons and interactive elements involved in the modified features, including:

- Global search controls and search results.
- Notification controls and menu actions.
- Locker assignment and unassignment controls.
- AI chatbot launcher, dragging, close, send, and conversation controls.
- Universal QR Portal navigation and QR actions.

For each visible control:

1. Identify its intended behavior.
2. Connect it to the correct event handler or API operation.
3. Validate its inputs.
4. Enforce server-side permissions.
5. Show an appropriate loading state while processing.
6. Prevent accidental duplicate submissions.
7. Display a clear success or failure result.
8. Keep frontend state synchronized with persisted backend state.
9. Ensure it remains usable on mobile and desktop.
10. Verify keyboard and accessibility behavior where applicable.

Remove inert controls, placeholder handlers, and misleading interactions. Do not make a button appear functional when its underlying operation has not been implemented.

Do not change unrelated working functionality without a clear technical reason.

# 8. UI/UX and Code Quality

Maintain a consistent visual style across the application.

- Reuse existing components, spacing, colors, typography, icons, and design tokens.
- Avoid unnecessary redesigns.
- Keep search results readable and relevant.
- Make notification empty states and unread states clear without unwanted green dots.
- Make locker assignment states unambiguous.
- Ensure the chatbot is compact, draggable, and unobtrusive.
- Ensure the QR Portal is easy to find and use.
- Avoid horizontal overflow, broken layouts, and overlapping elements.
- Support common desktop and mobile viewport sizes.
- Add appropriate accessibility labels, focus states, and keyboard interaction.
- Remove dead code and duplicated logic introduced by the changes.
- Preserve the existing coding conventions and architecture.

# 9. Database, Backend, and Security Requirements

Before introducing schema changes, inspect the current database and existing migrations.

- Use the project's existing database access patterns.
- Add only necessary migrations, indexes, constraints, or relationships.
- Preserve existing valid user, notification, locker, assignment, and branch records.
- Apply appropriate transactions for related operations.
- Prevent race conditions and duplicate assignment or notification records where applicable.
- Enforce permissions on the backend, not only in the UI.
- Validate all incoming inputs.
- Keep secrets out of source control.
- Avoid broad destructive data cleanup.
- Ensure development/demo fixtures cannot leak into production data.
- Follow the existing deployment and environment configuration conventions.
- Document any new environment variables and required external API configuration.

Do not disable security checks, authentication, or authorization to make tests pass.

# 10. Required Testing and Verification

Do not consider the task complete just because the interface renders or the code compiles.

Run the available checks in the existing repository:

- Dependency/build checks where appropriate.
- Linting and type checking where configured.
- Relevant unit tests.
- Backend/API integration tests.
- Frontend interaction tests.
- Database or migration validation where supported.
- Browser-based end-to-end testing where available.

Add tests for the reported bugs and the new functionality.

### Minimum regression test matrix

| Feature | Required verification |
|---|---|
| Global search | Correct matching records, no unrelated results, correct navigation |
| Search exclusion | Core Library Services absent from search |
| Search permissions | Unauthorized records never returned |
| Notifications | Real events generate persisted notifications |
| Notification UI | No demo data or unwanted green dots |
| Notification actions | Read, unread, mark all read, and other supported actions persist correctly |
| Notification isolation | Each user sees only authorized notifications |
| Locker assignment | Unassigned by default when no valid active assignment exists |
| Branch isolation | Correct assignment behavior in both branches |
| Assignment mutations | Successful assignment and removal persist correctly |
| Gemini integration | Real API call succeeds with a valid server-side credential |
| AI permissions | User and administrator receive only authorized information |
| Floating chatbot | Dragging, opening, closing, opacity, and viewport constraints work |
| Universal QR Portal | Navigation, supported QR operations, and validation work |
| Responsive UI | Modified features work on desktop and mobile |
| Existing features | No regressions in related application functionality |

Test edge cases such as empty data, invalid input, slow requests, API failures, expired sessions, repeated clicks, stale state, and concurrent operations.

If an external service cannot be tested because credentials, permissions, quotas, or configuration are unavailable, report the exact limitation and provide the required setup instructions. Do not pretend the integration passed.

# 11. Execution Order

Use the following order to minimize regressions:

1. Inspect the project and reproduce the reported bugs.
2. Identify the root causes and relevant dependencies.
3. Fix global search and remove Core Library Services from search.
4. Repair notification persistence, delivery, UI, and actions.
5. Correct locker assignment logic for both branches.
6. Implement the secure Gemini backend integration.
7. Build the floating, draggable chatbot interface.
8. Implement the Universal QR Portal.
9. Audit all related buttons and application interactions.
10. Run tests, fix regressions, and verify the modified workflows.
11. Review security, environment configuration, and database consistency.
12. Provide a final implementation report.

# 12. Final Delivery Report

When the work is complete, provide a concise but specific report containing:

- Files and modules modified.
- Root cause of each original bug.
- Changes made to global search, notifications, and locker assignment logic.
- How assignment correctness was verified in both branches.
- Gemini integration architecture and required environment variables, without exposing credentials.
- Chatbot UI and dragging behavior implemented.
- Universal QR Portal functionality implemented.
- Database migrations or configuration changes required.
- Tests executed and their actual pass/fail results.
- Any unresolved issues, external setup requirements, or limitations.
- Exact steps required to run and deploy the changes.

## Final non-negotiable requirements

- Modify the existing project directly.
- Fix the actual causes of bugs rather than hiding their symptoms.
- Do not introduce demo notifications or fabricated application records.
- Do not hardcode sensitive credentials.
- Do not falsely mark unassigned lockers as assigned.
- Keep both branches consistent and properly isolated.
- Do not bypass authentication, permissions, or backend validation.
- Do not claim that anything works unless it has been tested.
- Preserve existing working features.
- Finish all feasible implementation and verification steps before reporting completion.

Begin by inspecting the existing project and then execute the work systematically. Do not stop at a plan or ask for confirmation for routine implementation decisions.
</USER_REQUEST>
<ADDITIONAL_METADATA>
The current local time is: 2026-10-18T04:00:35+05:30.
</ADDITIONAL_METADATA>
# Instruqt API - Available User Fields

## Summary

This document lists all available fields that can be retrieved for users in the Instruqt GraphQL API.

## ✅ Currently Collected Fields

The script currently collects the following fields:

### From `UserProfile` (user.node.profile)
- **display_name** (String): User's display name (e.g., "John Doe")
- **email** (String): User's email address
- **avatar** (String): Gravatar URL for the user's profile picture

### From `TeamUserEdge` (user_edge)
- **role** (RoleName): User's role within the team
  - Possible values: `content_creator`, `owner`, `member`, `instructor`
- **scope** (ScopeName): User's scope within the team
  - Observed value: `all`

### From `User` (user.node)
- **id** (ID): Unique user identifier
- **is_anonymous** (Boolean): Whether the user account is anonymous
- **teams** (Array): List of teams the user is a member of
  - Each team includes: `id`, `name`, `slug`, `role`

## ❌ NOT Available Fields

The following fields were requested but are **NOT available** through the Instruqt API:

- ❌ **created_at / createdAt**: User creation date
- ❌ **last_seen_at / lastSeenAt**: Last activity date  
- ❌ **firstName**: User's first name
- ❌ **lastName**: User's last name
- ❌ **slug**: User's profile slug (exists in schema but always returns `null`)

### Note on Activity Data

The `UserReportItem` type does have a `lastStartedAt` field that shows when a user last started a track, but:
- It requires passing `input: {teamSlug: $teamSlug}` parameter
- It causes significant API performance issues (timeouts)
- It's not recommended for bulk user queries

## 🔍 Additional Available Fields (Not Currently Used)

The following fields are available but not currently collected:

### From `User` type
- **~~teams~~**: List of teams the user is a member of (✅ **NOW INCLUDED**)
- **segments**: User's segments
- **claims**: User's invite claims
- **accessibleTracks**: Tracks the user has access to
- **reportItem**: Statistics for the user (requires teamSlug input, may cause timeouts)
- **labReportItem**: Lab statistics for the user
- **supportVerificationHash**: Hash to identify user to support system

### From `UserDetails` type (user.node.details)
Note: Requires `teamSlug` argument
- **firstName** (String)
- **lastName** (String)  
- **email** (String)
- **emailConfirmed** (Boolean)
- **companyName** (String)
- **phoneNumber** (String)
- **jobTitle** (String)
- **jobLevel** (String)
- **countryCode** (String)
- **usState** (String)
- **consent** (Boolean)

**Important**: When we tested `details`, it returned errors requiring `teamID or teamSlug` argument for each user, suggesting it's not designed for bulk queries through the team users endpoint.

## 📊 Output Structure

### JSON Output (team_users_details.json)
```json
{
  "id": "abc123xyz",
  "email": "user@mydomain.lan",
  "name": "John Doe",
  "display_name": "John Doe",
  "role": "content_creator",
  "scope": "all",
  "is_anonymous": false,
  "avatar": "https://www.gravatar.com/avatar/...",
  "teams": []
}
```

### Text Output (team_users_list.txt)
```
Name: John Doe
  Email: user@mydomain.lan
  Role: content_creator
  Scope: all
  ID: abc123xyz
  Anonymous: False
  Teams: 0
  Avatar: https://www.gravatar.com/avatar/...
```

## 🔧 Customization

To add more fields, you would need to:

1. Update the GraphQL query in `get_team_users()` function
2. Update the data processing in the main loop
3. Update the file writing sections
4. Be aware of API performance implications for complex nested queries

## 📝 Notes

- The API uses a `TeamUserEdge` structure where user data is in `edge.node` and team-specific data (role, scope) is on the edge itself
- All date/timestamp fields appear to be unavailable through the team users query
- The `slug` field in UserProfile always returns `null` for all users
- Performance degrades significantly when trying to fetch report/activity data for all users
- The `teams` field returns an empty array when querying users through a specific team's context
  - This is expected behavior as the query is already scoped to a particular team
  - To get a user's full team membership list, you would need to query the user directly (not through a team)

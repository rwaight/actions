# Instruqt API - Available Track Fields

## Summary

This document lists all available fields that can be retrieved for tracks in the Instruqt GraphQL API.

## ✅ Currently Collected Fields

The script currently collects the following fields:

### From `Track` object

- **id** (ID): Unique track identifier
- **slug** (String): URL-friendly track identifier
- **title** (String): Track title/name
- **description** (String): Track description
- **tags** (Array[String]): Tags associated with the track
- **level** (String): Difficulty level (e.g., "beginner", "intermediate", "advanced")
- **teaser** (String): Short teaser text for the track
- **icon** (String): Icon URL or identifier for the track
- **owner** (String): Owner of the track
- **published** (Boolean): Whether the track is published
- **private** (Boolean): Whether the track is private
- **maintenance** (Boolean): Whether the track is in maintenance mode

### From `Challenge` (nested in track)

**Always Collected:**
- **id** (ID): Unique challenge identifier
- **slug** (String): URL-friendly challenge identifier  
- **title** (String): Challenge title
- **type** (String): Type of challenge

**Conditionally Collected** (when `include-challenge-assignments: 'true'`):
- **assignment** (String): Challenge assignment text (can be lengthy)

> **Note**: Assignment text is excluded by default to reduce output size and improve performance. Enable it using the `include-challenge-assignments` input when needed.

## 📊 Output Structure

### JSON Output (team_tracks_details.json)

```json
{
  "id": "abc123xyz",
  "slug": "my-track",
  "title": "Introduction to Kubernetes",
  "description": "Learn the basics of Kubernetes...",
  "level": "beginner",
  "published": true,
  "private": false,
  "maintenance": false,
  "tags": ["kubernetes", "containers", "docker"],
  "teaser": "Get started with Kubernetes",
  "icon": "https://...",
  "owner": "team-slug",
  "challenge_count": 5,
  "challenges": [
    {
      "id": "challenge123",
      "slug": "setup-cluster",
      "title": "Set Up Your Cluster",
      "type": "challenge",
      "assignment": "In this challenge, you will..."
    }
  ]
}
```

### Text Output (team_tracks_list.txt)

```
Title: Introduction to Kubernetes
  Slug: my-track
  ID: abc123xyz
  Level: beginner
  Published: True
  Private: False
  Maintenance: False
  Challenges: 5
  Tags: kubernetes, containers, docker
  Description: Learn the basics of Kubernetes...
```

## 🔧 Customization

To add more fields, you would need to:

1. Update the GraphQL query in `get_team_tracks()` function
2. Update the data processing in the main loop
3. Update the file writing sections
4. Be aware of API performance implications for complex nested queries

## 📝 Notes

- The `tracks` query accepts optional parameters: `teamSlug`, `teamID`, `organizationSlug`, `organizationID`
- The script queries tracks by team slug for team-specific track lists
- Tracks can have multiple challenges, each with their own properties
- The `published`, `private`, and `maintenance` flags control track visibility and status
- Tags are useful for categorizing and filtering tracks
- Challenge types may include various formats (specific types depend on Instruqt's implementation)

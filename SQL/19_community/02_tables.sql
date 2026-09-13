-- SALUD v4.0.10 · módulo 19 · schema community
-- Generado de diagram_19_community.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "community"."public_profiles" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "slug" varchar NOT NULL,
    "display_name" varchar NOT NULL,
    "headline" varchar,
    "biography" text,
    "avatar_file_id" uuid,
    "cover_file_id" uuid,
    "verification_status_concept_id" uuid,
    "visibility_concept_id" uuid,
    "accepts_reviews" boolean,
    "comments_default_enabled" boolean,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_public_profiles" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."social_posts" (
    "id" uuid NOT NULL,
    "author_public_profile_id" uuid NOT NULL,
    "post_type_concept_id" uuid NOT NULL,
    "body_text" text NOT NULL,
    "visibility_concept_id" uuid,
    "comments_enabled" boolean,
    "health_data_screening_status_concept_id" uuid NOT NULL,
    "moderation_status_concept_id" uuid NOT NULL,
    "publication_status_concept_id" uuid NOT NULL,
    "published_at" timestamptz,
    "edited_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_social_posts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."post_media" (
    "id" uuid NOT NULL,
    "post_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "media_role_concept_id" uuid NOT NULL,
    "alt_text" varchar,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_post_media" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."service_reviews" (
    "id" uuid NOT NULL,
    "target_public_profile_id" uuid NOT NULL,
    "reviewer_patient_profile_id" uuid NOT NULL,
    "verified_encounter_id" uuid,
    "overall_rating" smallint NOT NULL,
    "review_text" text,
    "reviewer_display_mode_concept_id" uuid,
    "verification_status_concept_id" uuid NOT NULL,
    "moderation_status_concept_id" uuid NOT NULL,
    "publication_status_concept_id" uuid NOT NULL,
    "published_at" timestamptz,
    "edited_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_service_reviews" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."review_dimension_scores" (
    "id" uuid NOT NULL,
    "review_id" uuid NOT NULL,
    "dimension_concept_id" uuid NOT NULL,
    "score" smallint NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_review_dimension_scores" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."review_responses" (
    "id" uuid NOT NULL,
    "review_id" uuid NOT NULL,
    "responder_public_profile_id" uuid NOT NULL,
    "response_text" text NOT NULL,
    "moderation_status_concept_id" uuid NOT NULL,
    "published_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_review_responses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."content_reports" (
    "id" uuid NOT NULL,
    "reporter_user_id" uuid NOT NULL,
    "target_type_concept_id" uuid NOT NULL,
    "target_id" uuid NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "detail_text" text,
    "status_concept_id" uuid NOT NULL,
    "assigned_moderator_user_id" uuid,
    "resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_content_reports" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."comments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "author_profile_id" uuid NOT NULL,
    "commentable_type_concept_id" uuid NOT NULL,
    "commentable_ref_id" uuid NOT NULL,
    "parent_comment_id" uuid,
    "root_comment_id" uuid,
    "thread_depth" integer,
    "body_text" text NOT NULL,
    "body_richtext_json" jsonb,
    "reply_count" integer,
    "reaction_count" integer,
    "is_edited" boolean,
    "edited_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_comments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."reactions" (
    "id" uuid NOT NULL,
    "actor_profile_id" uuid NOT NULL,
    "reactable_type_concept_id" uuid NOT NULL,
    "reactable_ref_id" uuid NOT NULL,
    "reaction_type_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_reactions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."mentions" (
    "id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_ref_id" uuid NOT NULL,
    "mentioned_profile_id" uuid NOT NULL,
    "offset_start" integer,
    "offset_end" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_mentions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."hashtags" (
    "id" uuid NOT NULL,
    "tag" varchar NOT NULL,
    "normalized_tag" varchar,
    "usage_count" bigint,
    "topic_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_hashtags" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."topics" (
    "id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "parent_topic_id" uuid,
    "specialty_concept_id" uuid,
    "follower_count" bigint,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_topics" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."content_hashtags" (
    "id" uuid NOT NULL,
    "hashtag_id" uuid NOT NULL,
    "content_type_concept_id" uuid NOT NULL,
    "content_ref_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_content_hashtags" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."groups" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "slug" varchar NOT NULL,
    "name" varchar NOT NULL,
    "description" text,
    "visibility_concept_id" uuid NOT NULL,
    "group_type_concept_id" uuid NOT NULL,
    "topic_id" uuid,
    "owner_profile_id" uuid,
    "cover_file_id" uuid,
    "member_count" integer,
    "post_count" integer,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_groups" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."group_members" (
    "id" uuid NOT NULL,
    "group_id" uuid NOT NULL,
    "member_profile_id" uuid NOT NULL,
    "member_role_concept_id" uuid NOT NULL,
    "join_status_concept_id" uuid NOT NULL,
    "joined_at" timestamptz,
    "invited_by_profile_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_group_members" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."post_shares" (
    "id" uuid NOT NULL,
    "post_id" uuid NOT NULL,
    "sharer_profile_id" uuid NOT NULL,
    "share_type_concept_id" uuid NOT NULL,
    "quote_text" text,
    "target_group_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_post_shares" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."bookmarks" (
    "id" uuid NOT NULL,
    "profile_id" uuid NOT NULL,
    "bookmarkable_type_concept_id" uuid NOT NULL,
    "bookmarkable_ref_id" uuid NOT NULL,
    "collection_name" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_bookmarks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."feed_items" (
    "id" uuid NOT NULL,
    "owner_profile_id" uuid NOT NULL,
    "item_type_concept_id" uuid NOT NULL,
    "source_type_concept_id" uuid NOT NULL,
    "source_ref_id" uuid NOT NULL,
    "origin_concept_id" uuid NOT NULL,
    "rank_score" numeric,
    "is_seen" boolean,
    "is_hidden" boolean,
    "surfaced_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_feed_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."polls" (
    "id" uuid NOT NULL,
    "post_id" uuid NOT NULL,
    "question" varchar NOT NULL,
    "allows_multiple" boolean NOT NULL,
    "closes_at" timestamptz,
    "total_votes" bigint,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_polls" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."poll_options" (
    "id" uuid NOT NULL,
    "poll_id" uuid NOT NULL,
    "label" varchar NOT NULL,
    "ordinal" integer,
    "vote_count" bigint,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_poll_options" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."poll_votes" (
    "id" uuid NOT NULL,
    "poll_id" uuid NOT NULL,
    "poll_option_id" uuid NOT NULL,
    "voter_profile_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_poll_votes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."conversations" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "conversation_type_concept_id" uuid NOT NULL,
    "group_id" uuid,
    "last_message_at" timestamptz,
    "message_count" integer,
    "pinned_message_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_conversations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."conversation_participants" (
    "id" uuid NOT NULL,
    "conversation_id" uuid NOT NULL,
    "participant_profile_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "joined_at" timestamptz,
    "last_read_message_id" uuid,
    "muted_until" timestamptz,
    "is_favorite" boolean NOT NULL DEFAULT false,
    "is_pinned" boolean NOT NULL DEFAULT false,
    "archived_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_conversation_participants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."direct_messages" (
    "id" uuid NOT NULL,
    "conversation_id" uuid NOT NULL,
    "sender_profile_id" uuid NOT NULL,
    "reply_to_message_id" uuid,
    "content_type_concept_id" uuid NOT NULL,
    "body_text" text,
    "attachment_file_id" uuid,
    "is_edited" boolean,
    "deleted_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "sent_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_direct_messages" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."message_receipts" (
    "id" uuid NOT NULL,
    "direct_message_id" uuid NOT NULL,
    "recipient_profile_id" uuid NOT NULL,
    "receipt_type_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_message_receipts" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."social_notifications" (
    "id" uuid NOT NULL,
    "recipient_profile_id" uuid NOT NULL,
    "notification_type_concept_id" uuid NOT NULL,
    "actor_profile_id" uuid,
    "source_type_concept_id" uuid NOT NULL,
    "source_ref_id" uuid NOT NULL,
    "preview_text" varchar,
    "is_read" boolean,
    "read_at" timestamptz,
    "notification_request_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_social_notifications" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."verified_badges" (
    "id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_ref_id" uuid NOT NULL,
    "badge_type_concept_id" uuid NOT NULL,
    "verification_method_concept_id" uuid NOT NULL,
    "verified_by_user_id" uuid,
    "evidence_ref" varchar,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_verified_badges" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."user_blocks" (
    "id" uuid NOT NULL,
    "blocker_profile_id" uuid NOT NULL,
    "blocked_profile_id" uuid NOT NULL,
    "reason_concept_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_user_blocks" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."moderation_queue" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "content_type_concept_id" uuid NOT NULL,
    "content_ref_id" uuid NOT NULL,
    "source_concept_id" uuid NOT NULL,
    "content_report_id" uuid,
    "priority_concept_id" uuid,
    "ml_score" numeric,
    "assigned_to_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "queued_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_moderation_queue" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."moderation_decisions" (
    "id" uuid NOT NULL,
    "moderation_queue_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "policy_concept_id" uuid NOT NULL,
    "rationale_text" text,
    "action_taken_concept_id" uuid,
    "decided_by_user_id" uuid NOT NULL,
    "decided_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_moderation_decisions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."moderation_strikes" (
    "id" uuid NOT NULL,
    "subject_profile_id" uuid NOT NULL,
    "moderation_decision_id" uuid NOT NULL,
    "severity_concept_id" uuid NOT NULL,
    "points" integer,
    "expires_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_moderation_strikes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."moderation_appeals" (
    "id" uuid NOT NULL,
    "moderation_decision_id" uuid NOT NULL,
    "appellant_profile_id" uuid NOT NULL,
    "reason_text" text NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "reviewed_by_user_id" uuid,
    "resolution_concept_id" uuid,
    "resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_moderation_appeals" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."social_follows" (
    "id" uuid NOT NULL,
    "follower_profile_id" uuid NOT NULL,
    "followable_type_concept_id" uuid NOT NULL,
    "followable_ref_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "notification_level_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_social_follows" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."prestige_scores" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_ref_id" uuid NOT NULL,
    "public_profile_id" uuid,
    "total_points" numeric NOT NULL,
    "level_concept_id" uuid,
    "rank_position" integer,
    "last_award_id" uuid,
    "calculated_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_prestige_scores" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."prestige_awards" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "subject_type_concept_id" uuid NOT NULL,
    "subject_ref_id" uuid NOT NULL,
    "public_profile_id" uuid,
    "direction_concept_id" uuid NOT NULL,
    "points" numeric NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "note" varchar,
    "awarded_by_user_id" uuid NOT NULL,
    "source_type" varchar,
    "source_ref_id" uuid,
    "balance_after" numeric,
    "idempotency_key" varchar NOT NULL,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_prestige_awards" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."feedback_tickets" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "ticket_number" varchar NOT NULL,
    "reporter_user_id" uuid NOT NULL,
    "reporter_type_concept_id" uuid,
    "category_concept_id" uuid NOT NULL,
    "subject" varchar NOT NULL,
    "description" text,
    "severity_concept_id" uuid,
    "channel_concept_id" uuid,
    "related_ref_type" varchar,
    "related_ref_id" uuid,
    "assigned_to_user_id" uuid,
    "resolution" text,
    "opened_at" timestamptz,
    "resolved_at" timestamptz,
    "closed_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_feedback_tickets" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."feedback_ticket_comments" (
    "id" uuid NOT NULL,
    "feedback_ticket_id" uuid NOT NULL,
    "author_user_id" uuid NOT NULL,
    "body" text NOT NULL,
    "is_internal" boolean,
    "visibility_concept_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_feedback_ticket_comments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."feedback_ticket_events" (
    "history_id" uuid NOT NULL,
    "feedback_ticket_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "from_status_concept_id" uuid,
    "to_status_concept_id" uuid NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "note" varchar,
    "changed_by_user_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    CONSTRAINT "pk_feedback_ticket_events" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "community"."comment_media" (
    "id" uuid NOT NULL,
    "comment_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "media_role_concept_id" uuid NOT NULL,
    "alt_text" varchar,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_comment_media" PRIMARY KEY ("id")
);

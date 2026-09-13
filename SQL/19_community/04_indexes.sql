-- SALUD v4.0.10 · módulo 19 · schema community
-- Generado de diagram_19_community.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_public_profiles_slug" ON "community"."public_profiles" ("slug");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_tenant_id" ON "community"."public_profiles" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_target_type_concept_id" ON "community"."public_profiles" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_avatar_file_id" ON "community"."public_profiles" ("avatar_file_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_cover_file_id" ON "community"."public_profiles" ("cover_file_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_verification_status_concept_id" ON "community"."public_profiles" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_visibility_concept_id" ON "community"."public_profiles" ("visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_status_concept_id" ON "community"."public_profiles" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_created_by_user_id" ON "community"."public_profiles" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_updated_by_user_id" ON "community"."public_profiles" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_public_profiles_tenant_id_status_concept_id" ON "community"."public_profiles" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_public_profiles_search" ON "community"."public_profiles" USING gin (to_tsvector('simple', (coalesce(display_name, '') || ' ' || coalesce(headline, ''))));

CREATE INDEX IF NOT EXISTS "ix_social_posts_author_public_profile_id" ON "community"."social_posts" ("author_public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_post_type_concept_id" ON "community"."social_posts" ("post_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_visibility_concept_id" ON "community"."social_posts" ("visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_health_data_screening_status_concept_id" ON "community"."social_posts" ("health_data_screening_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_moderation_status_concept_id" ON "community"."social_posts" ("moderation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_publication_status_concept_id" ON "community"."social_posts" ("publication_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_created_by_user_id" ON "community"."social_posts" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_posts_updated_by_user_id" ON "community"."social_posts" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_social_posts_search" ON "community"."social_posts" USING gin (to_tsvector('simple', (coalesce(body_text, ''))));

CREATE INDEX IF NOT EXISTS "ix_social_posts_profile_publication" ON "community"."social_posts" ("author_public_profile_id", "publication_status_concept_id", "published_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_post_media_post_id" ON "community"."post_media" ("post_id");

CREATE INDEX IF NOT EXISTS "ix_post_media_file_id" ON "community"."post_media" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_post_media_media_role_concept_id" ON "community"."post_media" ("media_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_post_media_created_by_user_id" ON "community"."post_media" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_target_public_profile_id" ON "community"."service_reviews" ("target_public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_reviewer_patient_profile_id" ON "community"."service_reviews" ("reviewer_patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_verified_encounter_id" ON "community"."service_reviews" ("verified_encounter_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_reviewer_display_mode_concept_id" ON "community"."service_reviews" ("reviewer_display_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_verification_status_concept_id" ON "community"."service_reviews" ("verification_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_moderation_status_concept_id" ON "community"."service_reviews" ("moderation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_publication_status_concept_id" ON "community"."service_reviews" ("publication_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_created_by_user_id" ON "community"."service_reviews" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_service_reviews_updated_by_user_id" ON "community"."service_reviews" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_service_reviews_search" ON "community"."service_reviews" USING gin (to_tsvector('simple', (coalesce(review_text, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_service_reviews_verified_encounter" ON "community"."service_reviews" ("reviewer_patient_profile_id", "target_public_profile_id", "verified_encounter_id") WHERE verified_encounter_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_review_dimension_scores_review_id" ON "community"."review_dimension_scores" ("review_id");

CREATE INDEX IF NOT EXISTS "ix_review_dimension_scores_dimension_concept_id" ON "community"."review_dimension_scores" ("dimension_concept_id");

CREATE INDEX IF NOT EXISTS "ix_review_responses_review_id" ON "community"."review_responses" ("review_id");

CREATE INDEX IF NOT EXISTS "ix_review_responses_responder_public_profile_id" ON "community"."review_responses" ("responder_public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_review_responses_moderation_status_concept_id" ON "community"."review_responses" ("moderation_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_review_responses_created_by_user_id" ON "community"."review_responses" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_review_responses_updated_by_user_id" ON "community"."review_responses" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_content_reports_reporter_user_id" ON "community"."content_reports" ("reporter_user_id");

CREATE INDEX IF NOT EXISTS "ix_content_reports_target_type_concept_id" ON "community"."content_reports" ("target_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_reports_reason_concept_id" ON "community"."content_reports" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_reports_status_concept_id" ON "community"."content_reports" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_reports_assigned_moderator_user_id" ON "community"."content_reports" ("assigned_moderator_user_id");

CREATE INDEX IF NOT EXISTS "ix_comments_tenant_id" ON "community"."comments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_comments_author_profile_id" ON "community"."comments" ("author_profile_id");

CREATE INDEX IF NOT EXISTS "ix_comments_commentable_type_concept_id" ON "community"."comments" ("commentable_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_comments_parent_comment_id" ON "community"."comments" ("parent_comment_id");

CREATE INDEX IF NOT EXISTS "ix_comments_root_comment_id" ON "community"."comments" ("root_comment_id");

CREATE INDEX IF NOT EXISTS "ix_comments_status_concept_id" ON "community"."comments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_comments_created_by_user_id" ON "community"."comments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_comments_updated_by_user_id" ON "community"."comments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_comments_tenant_id_status_concept_id" ON "community"."comments" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_comments_search" ON "community"."comments" USING gin (to_tsvector('simple', (coalesce(body_text, ''))));

CREATE INDEX IF NOT EXISTS "ix_comments_thread" ON "community"."comments" ("commentable_type_concept_id", "commentable_ref_id", "root_comment_id", "created_at");

CREATE INDEX IF NOT EXISTS "ix_reactions_actor_profile_id" ON "community"."reactions" ("actor_profile_id");

CREATE INDEX IF NOT EXISTS "ix_reactions_reactable_type_concept_id" ON "community"."reactions" ("reactable_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reactions_reaction_type_concept_id" ON "community"."reactions" ("reaction_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reactions_created_by_user_id" ON "community"."reactions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reactions_updated_by_user_id" ON "community"."reactions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_reactions_actor_target_type" ON "community"."reactions" ("actor_profile_id", "reactable_type_concept_id", "reactable_ref_id", "reaction_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_mentions_source_type_concept_id" ON "community"."mentions" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_mentions_mentioned_profile_id" ON "community"."mentions" ("mentioned_profile_id");

CREATE INDEX IF NOT EXISTS "ix_mentions_status_concept_id" ON "community"."mentions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_mentions_created_by_user_id" ON "community"."mentions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_mentions_updated_by_user_id" ON "community"."mentions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_hashtags_tag" ON "community"."hashtags" ("tag");

CREATE INDEX IF NOT EXISTS "ix_hashtags_topic_id" ON "community"."hashtags" ("topic_id");

CREATE INDEX IF NOT EXISTS "ix_hashtags_status_concept_id" ON "community"."hashtags" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_hashtags_created_by_user_id" ON "community"."hashtags" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_hashtags_updated_by_user_id" ON "community"."hashtags" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_topics_code" ON "community"."topics" ("code");

CREATE INDEX IF NOT EXISTS "ix_topics_parent_topic_id" ON "community"."topics" ("parent_topic_id");

CREATE INDEX IF NOT EXISTS "ix_topics_specialty_concept_id" ON "community"."topics" ("specialty_concept_id");

CREATE INDEX IF NOT EXISTS "ix_topics_status_concept_id" ON "community"."topics" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_topics_created_by_user_id" ON "community"."topics" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_topics_updated_by_user_id" ON "community"."topics" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_topics_search" ON "community"."topics" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_content_hashtags_hashtag_id" ON "community"."content_hashtags" ("hashtag_id");

CREATE INDEX IF NOT EXISTS "ix_content_hashtags_content_type_concept_id" ON "community"."content_hashtags" ("content_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_content_hashtags_created_by_user_id" ON "community"."content_hashtags" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_content_hashtags_updated_by_user_id" ON "community"."content_hashtags" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_groups_slug" ON "community"."groups" ("slug");

CREATE INDEX IF NOT EXISTS "ix_groups_tenant_id" ON "community"."groups" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_groups_visibility_concept_id" ON "community"."groups" ("visibility_concept_id");

CREATE INDEX IF NOT EXISTS "ix_groups_group_type_concept_id" ON "community"."groups" ("group_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_groups_topic_id" ON "community"."groups" ("topic_id");

CREATE INDEX IF NOT EXISTS "ix_groups_owner_profile_id" ON "community"."groups" ("owner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_groups_cover_file_id" ON "community"."groups" ("cover_file_id");

CREATE INDEX IF NOT EXISTS "ix_groups_status_concept_id" ON "community"."groups" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_groups_created_by_user_id" ON "community"."groups" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_groups_updated_by_user_id" ON "community"."groups" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_groups_tenant_id_status_concept_id" ON "community"."groups" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_groups_search" ON "community"."groups" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_group_members_group_id" ON "community"."group_members" ("group_id");

CREATE INDEX IF NOT EXISTS "ix_group_members_member_profile_id" ON "community"."group_members" ("member_profile_id");

CREATE INDEX IF NOT EXISTS "ix_group_members_member_role_concept_id" ON "community"."group_members" ("member_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_group_members_join_status_concept_id" ON "community"."group_members" ("join_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_group_members_invited_by_profile_id" ON "community"."group_members" ("invited_by_profile_id");

CREATE INDEX IF NOT EXISTS "ix_group_members_created_by_user_id" ON "community"."group_members" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_group_members_updated_by_user_id" ON "community"."group_members" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_post_shares_post_id" ON "community"."post_shares" ("post_id");

CREATE INDEX IF NOT EXISTS "ix_post_shares_sharer_profile_id" ON "community"."post_shares" ("sharer_profile_id");

CREATE INDEX IF NOT EXISTS "ix_post_shares_share_type_concept_id" ON "community"."post_shares" ("share_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_post_shares_target_group_id" ON "community"."post_shares" ("target_group_id");

CREATE INDEX IF NOT EXISTS "ix_post_shares_created_by_user_id" ON "community"."post_shares" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_post_shares_updated_by_user_id" ON "community"."post_shares" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bookmarks_profile_id" ON "community"."bookmarks" ("profile_id");

CREATE INDEX IF NOT EXISTS "ix_bookmarks_bookmarkable_type_concept_id" ON "community"."bookmarks" ("bookmarkable_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_bookmarks_created_by_user_id" ON "community"."bookmarks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_bookmarks_updated_by_user_id" ON "community"."bookmarks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_feed_items_owner_profile_id" ON "community"."feed_items" ("owner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_feed_items_item_type_concept_id" ON "community"."feed_items" ("item_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feed_items_source_type_concept_id" ON "community"."feed_items" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feed_items_origin_concept_id" ON "community"."feed_items" ("origin_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feed_items_created_by_user_id" ON "community"."feed_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_feed_items_updated_by_user_id" ON "community"."feed_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_polls_post_id" ON "community"."polls" ("post_id");

CREATE INDEX IF NOT EXISTS "ix_polls_status_concept_id" ON "community"."polls" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_polls_created_by_user_id" ON "community"."polls" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_polls_updated_by_user_id" ON "community"."polls" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_poll_options_poll_id" ON "community"."poll_options" ("poll_id");

CREATE INDEX IF NOT EXISTS "ix_poll_options_created_by_user_id" ON "community"."poll_options" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_poll_options_updated_by_user_id" ON "community"."poll_options" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_poll_votes_poll_id" ON "community"."poll_votes" ("poll_id");

CREATE INDEX IF NOT EXISTS "ix_poll_votes_poll_option_id" ON "community"."poll_votes" ("poll_option_id");

CREATE INDEX IF NOT EXISTS "ix_poll_votes_voter_profile_id" ON "community"."poll_votes" ("voter_profile_id");

CREATE INDEX IF NOT EXISTS "ix_poll_votes_created_by_user_id" ON "community"."poll_votes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_poll_votes_updated_by_user_id" ON "community"."poll_votes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_pinned_message_id" ON "community"."conversations" ("pinned_message_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_tenant_id" ON "community"."conversations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_conversation_type_concept_id" ON "community"."conversations" ("conversation_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_group_id" ON "community"."conversations" ("group_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_status_concept_id" ON "community"."conversations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_created_by_user_id" ON "community"."conversations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_updated_by_user_id" ON "community"."conversations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversations_tenant_id_status_concept_id" ON "community"."conversations" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_profile_pinned" ON "community"."conversation_participants" ("participant_profile_id", "is_pinned") WHERE is_pinned;

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_conversation_id" ON "community"."conversation_participants" ("conversation_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_participant_profile_id" ON "community"."conversation_participants" ("participant_profile_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_role_concept_id" ON "community"."conversation_participants" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_last_read_message_id" ON "community"."conversation_participants" ("last_read_message_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_status_concept_id" ON "community"."conversation_participants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_created_by_user_id" ON "community"."conversation_participants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_updated_by_user_id" ON "community"."conversation_participants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_conversation_id" ON "community"."direct_messages" ("conversation_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_sender_profile_id" ON "community"."direct_messages" ("sender_profile_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_reply_to_message_id" ON "community"."direct_messages" ("reply_to_message_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_content_type_concept_id" ON "community"."direct_messages" ("content_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_attachment_file_id" ON "community"."direct_messages" ("attachment_file_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_status_concept_id" ON "community"."direct_messages" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_created_by_user_id" ON "community"."direct_messages" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_updated_by_user_id" ON "community"."direct_messages" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_direct_messages_search" ON "community"."direct_messages" USING gin (to_tsvector('simple', (coalesce(body_text, ''))));

CREATE INDEX IF NOT EXISTS "ix_message_receipts_direct_message_id" ON "community"."message_receipts" ("direct_message_id");

CREATE INDEX IF NOT EXISTS "ix_message_receipts_recipient_profile_id" ON "community"."message_receipts" ("recipient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_message_receipts_receipt_type_concept_id" ON "community"."message_receipts" ("receipt_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_message_receipts_recorded_by_user_id" ON "community"."message_receipts" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_message_receipts_recorded_at" ON "community"."message_receipts" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_social_notifications_recipient_profile_id" ON "community"."social_notifications" ("recipient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_notification_type_concept_id" ON "community"."social_notifications" ("notification_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_actor_profile_id" ON "community"."social_notifications" ("actor_profile_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_source_type_concept_id" ON "community"."social_notifications" ("source_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_notification_request_id" ON "community"."social_notifications" ("notification_request_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_status_concept_id" ON "community"."social_notifications" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_created_by_user_id" ON "community"."social_notifications" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_notifications_updated_by_user_id" ON "community"."social_notifications" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_subject_type_concept_id" ON "community"."verified_badges" ("subject_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_badge_type_concept_id" ON "community"."verified_badges" ("badge_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_verification_method_concept_id" ON "community"."verified_badges" ("verification_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_verified_by_user_id" ON "community"."verified_badges" ("verified_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_status_concept_id" ON "community"."verified_badges" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_created_by_user_id" ON "community"."verified_badges" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_verified_badges_updated_by_user_id" ON "community"."verified_badges" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_blocks_blocker_profile_id" ON "community"."user_blocks" ("blocker_profile_id");

CREATE INDEX IF NOT EXISTS "ix_user_blocks_blocked_profile_id" ON "community"."user_blocks" ("blocked_profile_id");

CREATE INDEX IF NOT EXISTS "ix_user_blocks_reason_concept_id" ON "community"."user_blocks" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_blocks_status_concept_id" ON "community"."user_blocks" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_user_blocks_created_by_user_id" ON "community"."user_blocks" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_user_blocks_updated_by_user_id" ON "community"."user_blocks" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_tenant_id" ON "community"."moderation_queue" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_content_type_concept_id" ON "community"."moderation_queue" ("content_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_source_concept_id" ON "community"."moderation_queue" ("source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_content_report_id" ON "community"."moderation_queue" ("content_report_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_priority_concept_id" ON "community"."moderation_queue" ("priority_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_assigned_to_user_id" ON "community"."moderation_queue" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_status_concept_id" ON "community"."moderation_queue" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_created_by_user_id" ON "community"."moderation_queue" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_updated_by_user_id" ON "community"."moderation_queue" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_queue_tenant_id_status_concept_id" ON "community"."moderation_queue" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_moderation_queue_id" ON "community"."moderation_decisions" ("moderation_queue_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_decision_concept_id" ON "community"."moderation_decisions" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_policy_concept_id" ON "community"."moderation_decisions" ("policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_action_taken_concept_id" ON "community"."moderation_decisions" ("action_taken_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_decided_by_user_id" ON "community"."moderation_decisions" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_created_by_user_id" ON "community"."moderation_decisions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_decisions_updated_by_user_id" ON "community"."moderation_decisions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_strikes_subject_profile_id" ON "community"."moderation_strikes" ("subject_profile_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_strikes_moderation_decision_id" ON "community"."moderation_strikes" ("moderation_decision_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_strikes_severity_concept_id" ON "community"."moderation_strikes" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_strikes_status_concept_id" ON "community"."moderation_strikes" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_strikes_created_by_user_id" ON "community"."moderation_strikes" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_strikes_updated_by_user_id" ON "community"."moderation_strikes" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_moderation_decision_id" ON "community"."moderation_appeals" ("moderation_decision_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_appellant_profile_id" ON "community"."moderation_appeals" ("appellant_profile_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_status_concept_id" ON "community"."moderation_appeals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_reviewed_by_user_id" ON "community"."moderation_appeals" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_resolution_concept_id" ON "community"."moderation_appeals" ("resolution_concept_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_created_by_user_id" ON "community"."moderation_appeals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_moderation_appeals_updated_by_user_id" ON "community"."moderation_appeals" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_follows_follower_profile_id" ON "community"."social_follows" ("follower_profile_id");

CREATE INDEX IF NOT EXISTS "ix_social_follows_followable_type_concept_id" ON "community"."social_follows" ("followable_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_follows_status_concept_id" ON "community"."social_follows" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_follows_notification_level_concept_id" ON "community"."social_follows" ("notification_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_social_follows_created_by_user_id" ON "community"."social_follows" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_social_follows_updated_by_user_id" ON "community"."social_follows" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_social_follows_actor_target" ON "community"."social_follows" ("follower_profile_id", "followable_type_concept_id", "followable_ref_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_prestige_scores_subject" ON "community"."prestige_scores" ("tenant_id", "subject_type_concept_id", "subject_ref_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_scores_public_profile_id" ON "community"."prestige_scores" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_scores_level_concept_id" ON "community"."prestige_scores" ("level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_scores_total_points" ON "community"."prestige_scores" ("tenant_id", "total_points");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_prestige_awards_idempotency_key" ON "community"."prestige_awards" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_prestige_awards_subject" ON "community"."prestige_awards" ("tenant_id", "subject_type_concept_id", "subject_ref_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_awards_public_profile_id" ON "community"."prestige_awards" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_awards_awarded_by_user_id" ON "community"."prestige_awards" ("awarded_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_awards_reason_concept_id" ON "community"."prestige_awards" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prestige_awards_recorded_at" ON "community"."prestige_awards" ("recorded_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_feedback_tickets_ticket_number" ON "community"."feedback_tickets" ("tenant_id", "ticket_number");

CREATE INDEX IF NOT EXISTS "ix_feedback_tickets_reporter_user_id" ON "community"."feedback_tickets" ("reporter_user_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_tickets_category_concept_id" ON "community"."feedback_tickets" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_tickets_status_concept_id" ON "community"."feedback_tickets" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_tickets_severity_concept_id" ON "community"."feedback_tickets" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_tickets_assigned_to_user_id" ON "community"."feedback_tickets" ("assigned_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_tickets_opened_at" ON "community"."feedback_tickets" ("opened_at");

CREATE INDEX IF NOT EXISTS "ix_feedback_ticket_comments_feedback_ticket_id" ON "community"."feedback_ticket_comments" ("feedback_ticket_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_ticket_comments_author_user_id" ON "community"."feedback_ticket_comments" ("author_user_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_ticket_comments_created_at" ON "community"."feedback_ticket_comments" ("created_at");

CREATE INDEX IF NOT EXISTS "ix_feedback_ticket_events_feedback_ticket_id" ON "community"."feedback_ticket_events" ("feedback_ticket_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uk_feedback_ticket_events_revision" ON "community"."feedback_ticket_events" ("feedback_ticket_id", "revision_no");

CREATE INDEX IF NOT EXISTS "ix_feedback_ticket_events_to_status_concept_id" ON "community"."feedback_ticket_events" ("to_status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_feedback_ticket_events_recorded_at" ON "community"."feedback_ticket_events" ("recorded_at");

CREATE INDEX IF NOT EXISTS "ix_comment_media_comment_id" ON "community"."comment_media" ("comment_id");

CREATE INDEX IF NOT EXISTS "ix_comment_media_file_id" ON "community"."comment_media" ("file_id");

CREATE INDEX IF NOT EXISTS "ix_comment_media_media_role_concept_id" ON "community"."comment_media" ("media_role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_comment_media_created_by_user_id" ON "community"."comment_media" ("created_by_user_id");

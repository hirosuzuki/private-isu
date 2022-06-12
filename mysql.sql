CREATE INDEX `post_id@comments` ON comments (post_id);
CREATE INDEX `post_id-created_at@comments` ON comments (post_id, created_at);

CREATE INDEX `created_at@posts` ON posts (created_at desc);
CREATE INDEX `user_id@comments` ON comments (user_id);

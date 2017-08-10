DROP TABLE IF EXISTS `queue_test`;
CREATE TABLE `queue_test` (
  `job_id` varchar(255) NOT NULL,
  `title` varchar(255),
  `scheduled_at` bigint(20) NOT NULL DEFAULT '0',
  `enqueued_at` datetime NOT NULL
) ENGINE=QUEUE;

DROP TABLE IF EXISTS `queue_test_without_scheduled_at`;

CREATE TABLE `queue_test_without_scheduled_at` (
  `job_id` varchar(255) NOT NULL,
  `title` varchar(255),
  `enqueued_at` datetime NOT NULL
) ENGINE=QUEUE;

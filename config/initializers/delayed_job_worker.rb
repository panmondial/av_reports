Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
require 'jobs/build_detail'
require 'jobs/build_basic'
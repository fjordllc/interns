# frozen_string_literal: true

require 'active_record/fixtures'

ActiveRecord::FixtureSet.create_fixtures 'db/fixtures', %i[
  acts_as_taggable_on/taggings
  acts_as_taggable_on/tags
  users
  announcements
  answers
  articles
  books
  borrowings
  categories
  checks
  comments
  companies
  correct_answers
  courses
  events
  followings
  reports
  learning_times
  learnings
  memos
  notifications
  pages
  participations
  practices
  products
  questions
  reactions
  reservations
  seats
  watches
  works
]

Rake::Task['bootcamp:statistics:save_learning_minute_statistics'].execute

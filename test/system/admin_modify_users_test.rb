# frozen_string_literal: true

require "application_system_test_case"

class AdminModifyUsersTest < ApplicationSystemTestCase
  setup { login_user "komagata", "testtest" }

  test "accessed by non-administrative users" do
    login_user "yamada", "testtest"
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    assert_text "管理者としてログインしてください"
  end

  test "an error occurs when updating user-data" do
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    fill_in "user_login_name", with: "komagata"
    click_on "更新する"
    assert_text "ユーザー名 はすでに存在します。"
  end

  test "update user-data and update users" do
    user = users(:hatsuno)
    visit edit_admin_user_path(user.id)
    fill_in "user_login_name", with: "hatsuno-1"
    click_on "更新する"
    assert_text "ユーザーを更新しました。"
  end

  test "user can delete and all related data is deleted" do
    me    = users(:komagata)
    users = User.where.not("id = ?", me.id).all

    users.each do |user|
      # モデルレコード集計用のカラムをセットする
      params = {
        "User"         => { "id"      => [user.id] },
        "Learning"     => { "user_id" => [user.id] },
        "Comment"      => { "user_id" => [user.id] },
        "Report"       => { "user_id" => [user.id] },
        "Check"        => { "user_id" => [user.id] },
        "Footprint"    => { "user_id" => [user.id] },
        "Notification" => { "user_id" => [user.id] },
        "Image"        => { "user_id" => [user.id] },
        "Product"      => { "user_id" => [user.id] },
        "Question"     => { "user_id" => [user.id] },
        "Answer"       => { "user_id" => [user.id] },
        "Announcement" => { "user_id" => [user.id] },
      }

      # ブラウザテスト
      visit admin_users_path
      find("#delete-#{user.id}").click
      page.driver.browser.switch_to.alert.accept
      assert_text "#{user.full_name} さんを削除しました。"
      assert_raises(Capybara::ElementNotFound) { find_by_id("#delete-#{me.id}") }

      # 削除後のレコード件数を集計
      params.each do |p|
        assert_equal fetch_count(model = p[0], params = p[1]), 0
      end
    end
  end

  private
    # モデル名の文字列からモデルを取得し、条件に合致するレコード件数を取得する関数
    # モデル名からモデルを取得できなかった場合、エラーを返す
    # 複数条件にも対応している
    #
    # @param [String]  model_name
    # @param [Array]   params
    # @param [Boolean] need_model_name (default = false)
    # @example
    # Case 1:
    #   fetch_count("User", { "id" => [1] }, true)
    #     SQL : User.where("id = ?", 1)
    #     # => { "User" => 1 }
    # Case 2:
    #   fetch_count("User", { "name" => ["%sam%", "like"] })
    #     SQL : User.where("name like ?", "%sam%")
    #     # => 10
    # Case 3:
    #   fetch_count("User", { "age" => [20,  ">="], "age" => [40, "<="] })
    #     SQL : User.where("age >= ?", "20").where("age <= ?", 40)
    #     # => 20
    #
    def fetch_count(model_name, params, need_model_name = false)
      begin
        model = model_name.constantize
      rescue => e
        raise "#{model_name} is not found in models."
      end

      params.each do |params|
        model = set_where(model, params[0], params[1])
      end
      (need_model_name) ? { model_name => model.count } : model.count
    end

    # fetch_count関数で使うモデルにガシガシwhereをくっつけていく関数
    # @param model       [Object]
    # @param column_name [String]
    # @param params      [Array]
    # @example
    # Case 1:
    #   set_where(User, "id", [1])
    #     # => User.where("id = ?", 1)
    # Case 2:
    #   set_where(User, "name", ["%sam%", "like"])
    #     # => User.where("name like ?", "%sam%")
    def set_where(model, column_name, params)
      operator  = (params.length == 1) ? "=" : params[1]
      val       = params[0]
      where_buf = "#{column_name} #{operator} ?"
      model.where(where_buf, val)
    end
end

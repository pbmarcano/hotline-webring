require "rails_helper"

RSpec.describe RedirectionsController do
  describe "GET :next" do
    it "redirects to the next site" do
      gabe = Redirection.find_by!(slug: "gabe")
      next_redirection = gabe.next

      get :next, params: { slug: gabe.slug }

      expect(response).to redirect_to(next_redirection.url)
    end
  end

  [:next, :previous].each do |action|
    describe "GET #{action}" do
      it "creates a Redirection if it doesn't exist" do
        new_slug = "new"
        url = "http://example.com"
        first_redirection = Redirection.first
        old_next = first_redirection.next

        request.env["HTTP_REFERER"] = url
        get action, params: { slug: new_slug }

        new_redirection = Redirection.last
        expect(new_redirection.slug).to eq new_slug
        expect(first_redirection.reload.next).to eq new_redirection
      end

      it "ignores requests from http://example.dev" do
        request.env["HTTP_REFERER"] = "http://example.dev"

        get action, params: { slug: "whatever" }

        expect(response).to redirect_to page_path(:localhost)
      end

      context "when there is no referrer" do
        it "redirects to the first redirection's next/previous URL" do
          new_slug = "new"

          get action, params: { slug: new_slug }

          if action == :next
            expect(response).to redirect_to Redirection.first.next_url
          else
            expect(response).to redirect_to Redirection.first.previous_url
          end
        end
      end
    end
  end

  describe "GET :previous" do
    it "redirects to the previous site" do
      gabe = Redirection.find_by!(slug: "gabe")
      previous = Redirection.find_by!(next: gabe)

      get :previous, params: { slug: gabe.slug }

      expect(response).to redirect_to(previous.url)
    end
  end
end

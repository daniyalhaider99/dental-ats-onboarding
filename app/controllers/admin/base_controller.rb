module Admin
  class BaseController < ApplicationController
    # Authentication is out of scope for the MVP (PRD section 13). Every request in
    # this namespace acts as the admin; the actor is named so the document policy has
    # something concrete to authorise and real accounts can replace it later.
    def current_actor
      :admin
    end
  end
end

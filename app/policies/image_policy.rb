class ImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.present?
  end

  def destroy?
    user.present? && record.user == user
  end

  def update?
    user.present? && record.user == user
  end

  def like?
    user.present?
  end
end

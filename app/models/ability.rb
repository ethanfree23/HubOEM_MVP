class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      #UserGroup.elevation   -> 0->Inactive
      #                      -> 1->OEM
      #                      -> 2->EndUser
      #                      -> 9->Admin

      group = user.group
      elevation = group.elevation
      can [:quote, :read], group.conversations
      can [:create, :read], group.messages

      can :manage, user if elevation > 0
      can :read, group.users if elevation > 0
      can :manage, group if elevation > 0

      can :read, Onboarding
      can :create, Feedback

      if elevation == 9
        can :manage, :all
      end

      if elevation == 1
        can :read, Group
        can [:manage], PartQuote
        can :read, RecurringOrder

        can [:create, :index, :resend_email], Onboarding

        can [:manage], Machine

        can [:manage], Document

        can [:manage], Part

        can [:manage], MInstance
        can :manage, PInstance

        can :manage, Order
        can :manage, Invoice
        can :manage, LineItem
        can :manage, LineItemInstance

        can [:create, :index], Conversation

      end
      if elevation == 2
        can [:read, :index], MInstance
        can :read, PInstance
        can :read, Document
        can [:create, :read], Conversation
        can [:create, :read], Message
        can :read, Group
        can [:create, :read], PartQuote

        can [:index, :oem_order], Order
        can :manage, Order
        can [:read, :payment, :submit_payment], Invoice
        can :read, Payment

        # TODO: Fix cart routes, they should be able to see THEIR cart. Its setup where all actions are done on the
        # collection and they can only see their cart. I mean it works but its not good.
        can :manage, Cart
        # can :manage, group.cart

        can :manage, RecurringOrder
        can :manage, RecurringManifest
      end
    end
    rescue ActiveRecord::RecordNotFound => e
      # do nothing. User has no elevation, and as such cannot do anything.
  end
end

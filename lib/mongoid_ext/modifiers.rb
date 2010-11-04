# encoding: UTF-8
module MongoidExt
  module Modifiers
    extend ActiveSupport::Concern

    module ClassMethods
      def increment(conditions, update)
        _apply_modifier('$inc', conditions, update)
      end

      def decrement(conditions, update)
        update.each do |k, v|
          update[k] = -v.abs
        end

        _apply_modifier('$inc', conditions, update)
      end

      def override(conditions, update) # set() is already taken :(
        _apply_modifier('$set', conditions, update)
      end

      def unset(conditions, update)
        _apply_modifier('$unset', conditions, update)
      end

      def push(conditions, update)
        _apply_modifier('$push', conditions, update)
      end

      def push_all(conditions, update)
        _apply_modifier('$pushAll', conditions, update)
      end

      def push_uniq(conditions, update)
        _apply_modifier('$addToSet', conditions, update)
      end

      def pull(conditions, update)
        _apply_modifier('$pull', conditions, update)
      end

      def pull_all(conditions, update)
        _apply_modifier('$pullAll', conditions, update)
      end

      def pop(conditions, update)
        _apply_modifier('$pop', conditions, update)
      end

      private
      def _apply_modifier(modifier, conditions, update)
        collection.update(conditions, {modifier => update}, :multi => true)
      end
    end

    module InstanceMethods
      def unset(update)
        self.class.unset({:_id => id}, update)
      end

      def decrement(update)
        self.class.decrement({:_id => id}, update)
      end

      def override(update)
        self.class.override({:_id => id}, update)
      end

      def push(update)
        self.class.push({:_id => id}, update)
      end

      def pull(update)
        self.class.pull({:_id => id}, update)
      end

      def push_uniq(update)
        self.class.push_uniq({:_id => id}, update)
      end

      def pop(update)
        self.class.pop({:_id => id}, update)
      end
    end
  end
end

Mongoid::Document.send(:include, MongoidExt::Modifiers)

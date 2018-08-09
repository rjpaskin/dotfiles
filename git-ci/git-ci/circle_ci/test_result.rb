module GitCI
  class CircleCI
    class TestResult < JSONStruct
      accessors :classname, :file, :name, :result, :run_time

      def failed?
        result == "failure"
      end
    end
  end
end

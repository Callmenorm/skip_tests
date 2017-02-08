defmodule SkipTests.Parse.Scheduler do
    use GenServer

    @xml_dir "./xml"
    @parsed_dir "./parsed_xml"
    def start_link do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(state) do
        set_timeout()
        {:ok, state}
    end

    def check_and_parse_files() do
        files = SkipTests.Parse.XML.look_for_files(@xml_dir)
        |> Enum.map(fn(filename) -> {filename, File.read(filename)} end)
        |> Enum.filter(fn(x) ->
            case x do
                {_filename, {:ok, _xml_str}} ->
                    true
                _ -> false
            end
        end)
        |> Enum.map(fn(x) ->
            {filename, {:ok, xml_str}} = x
            retail_items = SkipTests.Parse.XML.get_retail_items(xml_str)
            [head | _tail] = retail_items
            %{value: values} = head
            mapped_values = Enum.reduce(values, %{}, fn(value, acc) ->
                mapped_value = Enum.into(value.attr, %{})
                Map.put_new(acc, mapped_value[:ItemNo], mapped_value)
            end)
            {filename, mapped_values}
        end)
        |> Enum.map(fn(x) ->
                {filename, _} = x
                "#{@xml_dir}/" <> file = filename

                File.rename(filename, "#{@parsed_dir}/#{file}")
                x
            end)
        {:ok, files}
    end

    def handle_info(:check, state) do
        set_timeout()
        case check_and_parse_files() do
            {:ok, parsed_files} ->
                new_state = Enum.reduce(parsed_files, state, fn(file, acc_state) ->
                        {filename, mapped_values} = file
                        Map.put_new(acc_state, filename, mapped_values)
                    end)
                {:noreply, new_state}
            {:error, _} ->
                {:noreply, state}
        end
    end

    defp set_timeout() do
        Process.send_after(self(), :check, 1000 * 60 * 1) # send :check after 5 minutes
    end
end
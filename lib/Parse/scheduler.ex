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
        |> Enum.filter(fn(x) -> #filters out the unreadable files
            case x do
                {_filename, {:ok, _xml_str}} ->
                    true
                _ -> false
            end
        end)
        |> Enum.map(fn(x) -> #returns a tuple of filename and map of retail items
            {filename, {:ok, xml_str}} = x

            # error handling is probably going to blow this up
            # I'm not sure what happens when Quinn fails. Documentation is scarce
            # but it was very easy to use
            retail_items = SkipTests.Parse.XML.get_retail_items(xml_str)
            [head | _tail] = retail_items #assumes that there is only one retail items element
            %{value: values} = head
            #maps the ItemNo to the retail item element
            mapped_values = Enum.reduce(values, %{}, fn(value, acc) ->
                mapped_value = Enum.into(value.attr, %{})
                Map.put_new(acc, mapped_value[:ItemNo], mapped_value)
            end)
            {filename, mapped_values}
        end)
        |> Enum.map(fn(x) -> #moves the files to the parsed directory
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
                # maps the filename to the mapped retails items
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
        Process.send_after(self(), :check, 1000 * 60 * 5) # send :check after 5 minutes
    end
end
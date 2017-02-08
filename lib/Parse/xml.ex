defmodule SkipTests.Parse.XML do
    def look_for_files(dir_name) do
        case File.ls dir_name do
            {:ok, list_of_files} ->
                list_of_files
                |> Enum.map(fn(file) -> "#{dir_name}/#{file}" end)
            {:error, _} ->
                []
        end
    end

    def get_retail_items(xml_str) do
        Quinn.parse(xml_str)
        |> Quinn.find(:RetailItems)
    end

    def retail_item_list_to_map(%{attr: attrs}) do
        Enum.into(attrs, %{})
    end
end
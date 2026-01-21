import { useAppStore } from "../stores/appStore";
import { GroupSection } from "./GroupSection";
import { FileRow } from "./FileRow";
import { Search, Clock, Loader2 } from "lucide-react";
import { UNGROUPED_ID } from "../types";

export function FileList() {
  const searchQuery = useAppStore((state) => state.searchQuery);
  const searchResults = useAppStore((state) => state.searchResults);
  const isSearching = useAppStore((state) => state.isSearching);
  const recentFiles = useAppStore((state) => state.recentFiles);
  const getGroupsWithUngrouped = useAppStore(
    (state) => state.getGroupsWithUngrouped
  );
  const openFile = useAppStore((state) => state.openFile);

  const groups = getGroupsWithUngrouped();

  return (
    <div className="flex-1 overflow-y-auto px-3 py-2">
      {searchQuery ? (
        // Search Results
        <div className="space-y-2">
          <div className="flex items-center gap-2 px-1 py-1.5 bg-gray-100/50 dark:bg-gray-800/50 rounded-lg">
            <Search className="w-3 h-3 text-blue-500" />
            <span className="text-xs font-semibold text-gray-700 dark:text-gray-300">
              Search Results
            </span>
            {!isSearching && searchResults.length > 0 && (
              <span className="text-xs text-gray-500">
                ({searchResults.length})
              </span>
            )}
          </div>

          {isSearching ? (
            <div className="flex items-center justify-center gap-2 py-8">
              <Loader2 className="w-4 h-4 animate-spin text-gray-400" />
              <span className="text-xs text-gray-500">Searching...</span>
            </div>
          ) : searchResults.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-8 text-gray-400">
              <Search className="w-6 h-6 mb-2" />
              <span className="text-xs">No results for "{searchQuery}"</span>
            </div>
          ) : (
            <div className="space-y-1">
              {searchResults.map((file) => (
                <FileRow
                  key={file.id}
                  file={file}
                  onOpen={() => openFile(file.path)}
                  showRemove={false}
                />
              ))}
            </div>
          )}
        </div>
      ) : (
        // Normal View
        <div className="space-y-3">
          {/* Recent Files */}
          {recentFiles.length > 0 && (
            <div className="space-y-2">
              <div className="flex items-center gap-2 px-1 py-1.5 bg-gray-100/50 dark:bg-gray-800/50 rounded-lg">
                <Clock className="w-3 h-3 text-blue-500" />
                <span className="text-xs font-semibold text-gray-700 dark:text-gray-300">
                  Recent
                </span>
                <span className="text-xs text-gray-500">
                  ({recentFiles.length})
                </span>
              </div>
              <div className="space-y-1">
                {recentFiles.map((file) => (
                  <FileRow
                    key={file.id}
                    file={file}
                    onOpen={() => openFile(file.path)}
                    showRemove={false}
                  />
                ))}
              </div>
            </div>
          )}

          {/* Groups */}
          {groups.map((group) => (
            <GroupSection
              key={group.id}
              group={group}
              isUngrouped={group.id === UNGROUPED_ID}
            />
          ))}
        </div>
      )}
    </div>
  );
}

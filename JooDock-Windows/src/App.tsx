import { useEffect, useCallback } from "react";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { useAppStore } from "./stores/appStore";
import { Header } from "./components/Header";
import { FileList } from "./components/FileList";
import { Footer } from "./components/Footer";
import { AddGroupModal } from "./components/AddGroupModal";

function App() {
  const loadData = useAppStore((state) => state.loadData);
  const addFile = useAppStore((state) => state.addFile);
  const isAddGroupModalOpen = useAppStore((state) => state.isAddGroupModalOpen);

  useEffect(() => {
    loadData();

    // Handle ESC key
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        invoke("hide_popup");
      }
    };

    window.addEventListener("keydown", handleKeyDown);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
    };
  }, [loadData]);

  // Handle file drop
  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      const files = Array.from(e.dataTransfer.files);
      files.forEach((file) => {
        // @ts-ignore - path exists on File in Tauri
        const path = file.path || file.name;
        if (path) {
          addFile(path);
        }
      });
    },
    [addFile]
  );

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
  }, []);

  return (
    <div
      className="w-[320px] h-[450px] bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl rounded-xl border border-gray-200/50 dark:border-gray-700/50 shadow-2xl flex flex-col overflow-hidden"
      onDrop={handleDrop}
      onDragOver={handleDragOver}
    >
      <Header />
      <div className="border-t border-gray-200/50 dark:border-gray-700/50" />
      <FileList />
      <div className="border-t border-gray-200/50 dark:border-gray-700/50" />
      <Footer />

      {isAddGroupModalOpen && <AddGroupModal />}
    </div>
  );
}

export default App;

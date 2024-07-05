<script lang="ts">
    import type { Message } from "$lib/types/Message";

    export let messages: Message[] = [];
</script>

{#each messages as message}
    {#if message?.role === "user"}
        <div
            class="group relative w-full items-start justify-start gap-4 max-sm:text-sm"
            role="presentation"
        >
            <div class="flex w-full flex-col gap-2">
                <div class="flex w-full flex-row flex-nowrap">
                    <p
                        class="disabled w-full appearance-none whitespace-break-spaces text-wrap break-words bg-inherit px-5 py-3.5 text-gray-500 dark:text-gray-400"
                    >
                        {message.text?.trim()}
                    </p>
                </div>
            </div>
        </div>
        {:else if message.role === "model"}
        <div
            class="group relative w-full items-start justify-start gap-4 max-sm:text-sm"
            role="presentation"
        >
            <div class="relative min-h-[calc(2rem+theme(spacing[3.5])*2)] min-w-[60px] break-words rounded-2xl border border-gray-100 bg-[#497BEF] px-5 py-3.5 prose-pre:my-2">
                <div class="prose max-w-none max-sm:prose-sm dark:prose-invert prose-headings:font-semibold prose-h1:text-lg prose-h2:text-base prose-h3:text-base">
                    <p
                        class="text-white"
                    >
                        {message.text?.trim()}
                    </p>
                </div>
            </div>
        </div>

    {/if}
{/each}

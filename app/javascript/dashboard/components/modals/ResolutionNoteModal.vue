<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import Editor from 'dashboard/components-next/Editor/Editor.vue';
import Button from 'dashboard/components-next/button/Button.vue';
import AddLabel from 'shared/components/ui/dropdown/AddLabel.vue';
import LabelDropdown from 'shared/components/ui/label/LabelDropdown.vue';
import { useConversationLabels } from 'dashboard/composables/useConversationLabels';

const props = defineProps({
  onClose: { type: Function, default: () => {} },
});

const emit = defineEmits(['save', 'close']);
const show = defineModel('show', { type: Boolean, default: false });
const { t } = useI18n();

const note = ref('');

const {
  savedLabels,
  activeLabels,
  accountLabels,
  addLabelToConversation,
  removeLabelFromConversation,
} = useConversationLabels();

const showLabelDropdown = ref(false);

const toggleLabels = () => {
  showLabelDropdown.value = !showLabelDropdown.value;
};

const closeDropdownLabel = () => {
  showLabelDropdown.value = false;
};

const closeModal = () => {
  show.value = false;
  emit('close');
  props.onClose();
  note.value = '';
  closeDropdownLabel();
};

const onSave = () => {
  if (!activeLabels.value.length) {
    useAlert(t('CONVERSATION.LABEL_REQUIRED_TO_RESOLVE'));
    return;
  }
  emit('save', note.value);
  closeModal();
};
</script>

<template>
  <woot-modal v-model:show="show" :on-close="closeModal">
    <woot-modal-header
      :header-title="t('CONVERSATION.RESOLUTION_NOTE.TITLE')"
    />
    <div class="p-8 flex flex-col gap-4">
      <Editor
        v-model="note"
        :placeholder="t('CONVERSATION.RESOLUTION_NOTE.PLACEHOLDER')"
        class="[&>div]:px-4"
      />
      <div
        v-on-clickaway="closeDropdownLabel"
        class="flex flex-wrap items-start gap-1 relative"
      >
        <AddLabel @add="toggleLabels" />
        <woot-label
          v-for="label in activeLabels"
          :key="label.id"
          :title="label.title"
          :description="label.description"
          show-close
          :color="label.color"
          variant="smooth"
          class="max-w-[calc(100%-0.5rem)]"
          @remove="removeLabelFromConversation"
        />
        <div
          v-if="showLabelDropdown"
          class="absolute left-0 top-full mt-1 w-full z-10"
        >
          <LabelDropdown
            :account-labels="accountLabels"
            :selected-labels="savedLabels"
            @add="addLabelToConversation"
            @remove="removeLabelFromConversation"
          />
        </div>
      </div>
      <div class="flex justify-end gap-2">
        <Button
          faded
          slate
          :label="t('CONVERSATION.RESOLUTION_NOTE.CANCEL')"
          @click="closeModal"
        />
        <Button
          v-if="activeLabels.length"
          :label="t('CONVERSATION.RESOLUTION_NOTE.SAVE')"
          @click="onSave"
        />
      </div>
    </div>
  </woot-modal>
</template>

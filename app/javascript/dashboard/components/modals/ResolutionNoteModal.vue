<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';
import Editor from 'dashboard/components-next/Editor/Editor.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  onClose: { type: Function, default: () => {} },
});

const emit = defineEmits(['save', 'close']);
const show = defineModel('show', { type: Boolean, default: false });
const { t } = useI18n();

const note = ref('');

const closeModal = () => {
  show.value = false;
  emit('close');
  props.onClose();
  note.value = '';
};

const onSave = () => {
  emit('save', note.value);
  closeModal();
};
</script>

<template>
  <woot-modal v-model:show="show" :on-close="closeModal">
    <woot-modal-header :header-title="t('CONVERSATION.RESOLUTION_NOTE.TITLE')" />
    <div class="p-8 flex flex-col gap-4">
      <Editor
        v-model="note"
        :placeholder="t('CONVERSATION.RESOLUTION_NOTE.PLACEHOLDER')"
        class="[&>div]:px-4"
      />
      <div class="flex justify-end gap-2">
        <Button
          faded
          slate
          :label="t('CONVERSATION.RESOLUTION_NOTE.CANCEL')"
          @click="closeModal"
        />
        <Button
          :label="t('CONVERSATION.RESOLUTION_NOTE.SAVE')"
          @click="onSave"
        />
      </div>
    </div>
  </woot-modal>
</template>

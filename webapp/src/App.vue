<template>
  <div class="container mx-auto p-4">
    <div v-for="backend in this.config.backends" :key="backend.name" class="mb-8 p-4 border rounded">
      <h2 class="text-xl mb-4">{{ backend.name }}</h2>
      <div class="flex gap-4">
        <button
          v-for="action in backend.actions"
          :key="action.name"
          @click="callApi(backend.endpoint, backend.containerid, backend.type, action.what)"
          class="px-4 py-2 rounded"
          :class="[action.color, { 'opacity-50': loading }]"
          :disabled="loading">
          {{ action.name }}
        </button>
      </div>
      <div
        v-if="messages[backend.type]"
        class="mt-4 p-4"
        :class="errors[backend.type] ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'">
        {{ messages[backend.type] }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      loading: false,
      messages: {},
      errors: {},
      config: null,
    };
  },
  async created() {
    try {
      const response = await fetch("/config.json");
      if (!response.ok) {
        throw new Error(`Failed to fetch config: ${response.statusText}`);
      }
      this.config = await response.json();
    } catch (err) {
      this.error = err.message;
    }
  },
  methods: {
    async callApi(endpoint, containerid, type, what) {
      const url = endpoint.replace("${containerid}", containerid).replace("${type}", type).replace("${what}", what);
      this.loading = true;
      this.messages[type] = "";
      this.errors[type] = false;

      try {
        const response = await fetch(url, {
          method: "POST",
          headers: {
            "X-API-Secret": this.config.api_secret,
          },
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || "Something went wrong");
        }

        this.messages[type] = data.message;
      } catch (err) {
        this.messages[type] = err.message;
        this.errors[type] = true;
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

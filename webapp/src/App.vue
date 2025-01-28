<template>
  <div class="container mx-auto p-4">
    <div v-for="backend in this.config.backends" :key="backend.name" class="mb-8 p-4 border rounded">
      <h2 class="text-xl mb-4">{{ backend.name }}</h2>
      <div class="flex gap-4 items-center">
        <input 
          v-if="backend.accepts_file"
          type="file"
          accept=".pdf,.csv"
          :id="'file-' + getIdentifier(backend.name)"
          class="hidden"
          @change="handleFileChange($event, backend)"
        />
        <label 
          v-if="backend.accepts_file"
          :for="'file-' + getIdentifier(backend.name)"
          class="cursor-pointer px-4 py-2 rounded border-2 bg-gray-500 hover:bg-gray-600 text-white border-gray-500"
        >
          Choose File
        </label>
        <span v-if="selectedFiles[getIdentifier(backend.name)]" class="text-sm text-gray-600">
          {{ selectedFiles[getIdentifier(backend.name)].name }}
        </span>
        <button
          v-for="action in backend.actions"
          :key="action.name"
          @click="callApi(backend.endpoint, backend.containerid, getIdentifier(backend.name), backend.type, action.what)"
          class="px-4 py-2 rounded border-2"
          :class="[action.color, { 'opacity-50': loading }]"
          :disabled="loading">
          {{ action.name }}
        </button>
      </div>
      <div v-if="messages[getIdentifier(backend.name)]" class="mt-4">
        <div v-if="errors[getIdentifier(backend.name)]" class="p-4 bg-red-100 text-red-700">
          {{ messages[getIdentifier(backend.name)] }}
        </div>
        <div v-else>
          <div class="p-4 bg-green-100 text-green-700">
            {{ messages[getIdentifier(backend.name)] }}
          </div>
          <div v-if="responseData[getIdentifier(backend.name)]?.data?.duplicate_import_ids?.length > 0" 
               class="mt-4 p-4 bg-yellow-100 text-yellow-700 rounded">
            <p class="font-semibold">{{ responseData[getIdentifier(backend.name)].data.duplicate_import_ids.length }} duplicate transactions were skipped</p>
            <div class="mt-2 text-sm">
              <div class="flex flex-wrap gap-2">
                <span v-for="id in responseData[getIdentifier(backend.name)].data.duplicate_import_ids" 
                      :key="id" 
                      class="px-2 py-1 bg-yellow-50 rounded">
                  {{ id }}
                </span>
              </div>
            </div>
          </div>
          <div v-if="responseData[getIdentifier(backend.name)]?.data?.transactions?.length > 0" class="mt-4">
            <h3 class="font-bold mb-2">Transactions</h3>
            <div class="overflow-x-auto">
              <table class="min-w-full bg-white border">
                <thead>
                  <tr>
                    <th class="border p-2">Date</th>
                    <th class="border p-2">Amount</th>
                    <th class="border p-2">Payee</th>
                    <th class="border p-2">Category</th>
                    <th class="border p-2">Memo</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="transaction in responseData[getIdentifier(backend.name)].data.transactions" 
                      :key="transaction.id" 
                      class="hover:bg-gray-50">
                    <td class="border p-2">{{ transaction.date }}</td>
                    <td class="border p-2" 
                        :class="transaction.amount < 0 ? 'text-red-600' : 'text-green-600'">
                      {{ (transaction.amount / 1000).toFixed(2) }} €
                    </td>
                    <td class="border p-2">{{ transaction.payee_name }}</td>
                    <td class="border p-2">{{ transaction.category_name || 'Uncategorized' }}</td>
                    <td class="border p-2">{{ transaction.memo || '-' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
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
      responseData: {},
      config: null,
      selectedFiles: {}
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
    getIdentifier(name) {
      return name.replace(/\s+/g, '_').toLowerCase();
    },
    handleFileChange(event, backend) {
      const identifier = this.getIdentifier(backend.name);
      this.selectedFiles[identifier] = event.target.files[0];
    },
    async callApi(endpoint, containerid, identifier, type, what) {
      const url = endpoint
        .replace("${containerid}", containerid)
        .replace("${type}", type)
        .replace("${what}", what);
      
      this.loading = true;
      this.messages[identifier] = "";
      this.errors[identifier] = false;
      this.responseData[identifier] = null;

      try {
        const formData = new FormData();
        if (this.selectedFiles[identifier]) {
          formData.append('file', this.selectedFiles[identifier]);
        }

        const response = await fetch(url, {
          method: "POST",
          headers: {
            "X-API-Secret": this.config.api_secret,
          },
          body: this.selectedFiles[identifier] ? formData : null
        });

        const data = await response.json();

        if (!response.ok) {
          throw new Error(data.error || "Something went wrong");
        }

        this.messages[identifier] = data.message;
        this.responseData[identifier] = data;
      } catch (err) {
        this.messages[identifier] = err.message;
        this.errors[identifier] = true;
      } finally {
        this.loading = false;
      }
    }
  },
};
</script>
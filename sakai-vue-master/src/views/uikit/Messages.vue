<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

const productDialog = ref(false);

const openWindow = () => {
    productDialog.value = true;
};

</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3>Lotes de café</h3>
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="Nuevo Lote" icon="pi pi-plus" class="p-button-success mr-2"
                                @click="openWindow" />
                        </div>
                    </template>
                    <template v-slot:end>
                        <span class="p-input-icon-left mb-2">
                            <i class="pi pi-search" />
                            <InputText placeholder="Lote a buscar" style="width: 100%" />
                        </span>
                    </template>
                </Toolbar>

                <DataTable :value="tablaLotes" class="p-datatable-gridlines" :paginator="true" :rows="10"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} lotes de café"
                    responsiveLayout="scroll">
                    <Column field="cns" header="Codigo del lote" :sortable="true" style="width:50px"></Column>
                    <Column field="grano" header="Tipo de grano" style="width:370px"></Column>
                    <Column style="width:180px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"></Button>
                        </template>
                    </Column>
                </DataTable>
                <Dialog v-model:visible="productDialog" :style="{ width: '450px' }" header="Ingresar nuevo lote de café" modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Name</label>
                        <InputText id="name"  required="true" autofocus :class="{ 'p-invalid': submitted && !product.name }" />
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>
